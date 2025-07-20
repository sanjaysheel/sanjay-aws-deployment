#!/bin/bash

# This script resets the Terraform backend configuration
# Usage: ./reset-backend.sh <environment>

ENV=${1:-dev}
STATE_KEY="terraform/$ENV/terraform.tfstate"

echo "Resetting backend for environment: $ENV"

# Create empty state file
echo '{
  "version": 4,
  "terraform_version": "1.4.0",
  "serial": 1,
  "lineage": "new-lineage-'$(date +%s)'",
  "outputs": {},
  "resources": [],
  "check_results": null
}' > empty.tfstate

# Upload to S3
aws s3 cp empty.tfstate s3://ind-tfstate-bucket/$STATE_KEY

# Update DynamoDB table with correct digest
DIGEST=$(md5sum empty.tfstate | cut -d' ' -f1)
aws dynamodb put-item \
  --table-name ind-tfstate-lock \
  --item \
  "{\"LockID\":{\"S\":\"ind-tfstate-bucket/$STATE_KEY\"},\"Digest\":{\"S\":\"$DIGEST\"}}" \
  --return-consumed-capacity TOTAL

echo "Backend reset complete"