#!/bin/bash

BUCKET="ind-tfstate-bucket"
DYNAMODB_TABLE="ind-tfstate-lock"
ENVIRONMENT="$1"
ACTION="$2"

if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <environment> <create|release|check>"
    exit 1
fi

LOCK_KEY="terraform/${ENVIRONMENT}/terraform.tfstate.lock"
LOCK_ID="terraform-${ENVIRONMENT}-$(date +%s)"
OPERATION_TYPE="terraform-${ACTION}"

case $ACTION in
    "create")
        echo "Creating state lock for environment: $ENVIRONMENT"
        
        # Check if old lock file exists
        OLD_LOCK_EXISTS=false
        if aws s3api head-object --bucket $BUCKET --key $LOCK_KEY 2>/dev/null; then
            echo "Old lock file exists, backing up..."
            aws s3 cp s3://$BUCKET/$LOCK_KEY s3://$BUCKET/$LOCK_KEY.backup
            OLD_LOCK_EXISTS=true
        fi
        
        LOCK_CONTENT=$(cat <<EOF
{
    "ID": "$LOCK_ID",
    "Operation": "$OPERATION_TYPE",
    "Info": "Terraform lock for $ENVIRONMENT environment",
    "Who": "github-actions",
    "Created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "Path": "terraform/${ENVIRONMENT}/terraform.tfstate",
    "Status": "ACTIVE",
    "Environment": "$ENVIRONMENT"
}
EOF
)
        
        # Try to create new lock file
        if echo "$LOCK_CONTENT" | aws s3 cp - s3://$BUCKET/$LOCK_KEY; then
            echo "New lock file created successfully"
            
            # Remove backup since new file was created
            if [ "$OLD_LOCK_EXISTS" = true ]; then
                aws s3 rm s3://$BUCKET/$LOCK_KEY.backup || true
            fi
            
            # Update DynamoDB with new lock
            aws dynamodb put-item \
                --table-name $DYNAMODB_TABLE \
                --item "{
                    \"LockID\": {\"S\": \"$LOCK_ID\"},
                    \"Environment\": {\"S\": \"$ENVIRONMENT\"},
                    \"S3Key\": {\"S\": \"$LOCK_KEY\"},
                    \"Created\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
                    \"Status\": {\"S\": \"ACTIVE\"}
                }"
            
            echo "TERRAFORM_LOCK_ID=$LOCK_ID" >> $GITHUB_ENV
        else
            echo "Failed to create new lock file"
            
            # Restore old lock file if it existed
            if [ "$OLD_LOCK_EXISTS" = true ]; then
                echo "Restoring old lock file..."
                aws s3 cp s3://$BUCKET/$LOCK_KEY.backup s3://$BUCKET/$LOCK_KEY
                aws s3 rm s3://$BUCKET/$LOCK_KEY.backup || true
            fi
            
            exit 1
        fi
        ;;
        
    "release")
        echo "Releasing state lock for environment: $ENVIRONMENT"
        
        aws s3 rm s3://$BUCKET/$LOCK_KEY || true
        
        aws dynamodb scan \
            --table-name $DYNAMODB_TABLE \
            --filter-expression "Environment = :env AND #status = :status" \
            --expression-attribute-names '{"#status": "Status"}' \
            --expression-attribute-values '{":env": {"S": "'$ENVIRONMENT'"}, ":status": {"S": "ACTIVE"}}' \
            --query 'Items[].LockID.S' \
            --output text | while read LOCK_ID; do
                aws dynamodb update-item \
                    --table-name $DYNAMODB_TABLE \
                    --key "{\"LockID\": {\"S\": \"$LOCK_ID\"}}" \
                    --update-expression "SET #status = :status" \
                    --expression-attribute-names '{"#status": "Status"}' \
                    --expression-attribute-values '{":status": {"S": "RELEASED"}}'
            done
        ;;
        
    "check")
        echo "Checking state lock for environment: $ENVIRONMENT"
        
        if aws s3api head-object --bucket $BUCKET --key $LOCK_KEY 2>/dev/null; then
            echo "Lock file in S3:"
            aws s3 cp s3://$BUCKET/$LOCK_KEY -
        else
            echo "No lock file in S3"
        fi
        
        echo -e "\nDynamoDB lock info:"
        aws dynamodb scan \
            --table-name $DYNAMODB_TABLE \
            --filter-expression "Environment = :env" \
            --expression-attribute-values '{":env": {"S": "'$ENVIRONMENT'"}}' \
            --output table
        ;;
esac