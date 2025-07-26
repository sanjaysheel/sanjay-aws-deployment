# Terraform AWS Deployment with GitHub Actions

A comprehensive Infrastructure as Code (IaC) solution for deploying AWS resources using Terraform with GitHub Actions CI/CD pipeline, featuring multi-environment support, remote state management, and automated deployments.

## 🏗️ Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   GitHub Repo   │────▶│  GitHub Actions  │────▶│   AWS Account   │
│                 │     │                  │     │                 │
│ • Terraform     │     │ • Plan/Apply     │     │ • S3 Buckets    │
│ • Workflows     │     │ • Multi-env      │     │ • DynamoDB      │
│ • Modules       │     │ • State Lock     │     │ • IAM Roles     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                │                          ▲
                                │                          │
                                ▼                          │
                        ┌──────────────────┐               │
                        │   Remote State   │───────────────┘
                        │                  │
                        │ • S3 Backend     │
                        │ • DynamoDB Lock  │
                        │ • State History  │
                        └──────────────────┘
  ```

## 📁 Project Structure

```
├── .github/workflows/
│   └── terraform.yml           # GitHub Actions CI/CD pipeline
├── environments/
│   ├── dev.tfvars             # Development environment variables
│   ├── stag.tfvars            # Staging environment variables
│   └── prod.tfvars            # Production environment variables
├── main_module/
│   ├── s3.tf                  # S3 bucket configuration
│   ├── dynamodb.tf            # DynamoDB table configuration
│   ├── provider.tf            # AWS provider setup
│   ├── variables.tf           # Input variables
│   └── outputs.tf             # Output values
├── modules/aws/
│   ├── s3/                    # Reusable S3 module
│   ├── dynamodb/              # Reusable DynamoDB module
│   └── sqs/                   # Reusable SQS module
├── scripts/
│   └── manage-state-lock.sh   # Custom state lock management
├── setup/
│   └── state-bucket.tf        # Initial state bucket setup
├── backend.tf.tmpl            # Backend configuration template
└── README.md                  # This documentation
```

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd sanjay-aws-deployment

# Create initial state bucket (one-time setup)
cd setup
terraform init
terraform apply
cd ..
```

### 2. Configure GitHub Secrets

Add these secrets in your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret Name | Description | Example |
|-------------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalr...` |
| `AWS_REGION` | Default AWS Region | `us-east-1` |

### 3. Deploy Infrastructure

1. Go to **Actions** tab in GitHub
2. Select **"Terraform AWS Deployment"**
3. Click **"Run workflow"**
4. Choose:
   - **Environment**: `dev`, `stag`, or `prod`
   - **Action**: `plan`, `apply`, or `destroy`
   - **Region**: Target AWS region
5. Click **"Run workflow"**

## 🔧 Configuration

### Environment Variables

Each environment has its own configuration file:

```hcl
# environments/dev.tfvars
environment = "dev"
aws_region  = "us-west-1"

# environments/prod.tfvars
environment = "prod"
aws_region  = "us-east-1"
```

### Backend Configuration

The system automatically configures remote state:

```hcl
terraform {
  backend "s3" {
    bucket         = "ind-tfstate-bucket"
    key            = "terraform/{environment}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ind-tfstate-lock"
  }
}
```

## 🏭 Modules

### S3 Module

Creates S3 buckets with environment-specific naming:

```hcl
module "s3_bucket" {
  source        = "../modules/aws/s3"
  bucket_name   = "data-test-first"
  environment   = var.environment
  tags          = local.common_tags
  force_destroy = true
}
```

**Features:**
- Unique bucket naming with random suffix
- Versioning enabled
- Environment-based configuration
- Proper ownership controls

### DynamoDB Module

Creates DynamoDB tables for application data:

```hcl
module "dynamodb_table" {
  source     = "../modules/aws/dynamodb"
  table_name = "user-data"
  environment = var.environment
  tags       = local.common_tags
}
```

## 🔄 CI/CD Pipeline

### Workflow Triggers

- **Push to main**: Automatic plan
- **Pull Request**: Automatic plan
- **Manual Dispatch**: Full control over environment and action

### Workflow Steps

1. **Setup**: Checkout code, configure Terraform and AWS credentials
2. **State Management**: Check/create state bucket and DynamoDB table
3. **Lock Management**: Custom state locking with audit trail
4. **Terraform Operations**: Init, plan, apply, or destroy
5. **Resource Import**: Handle existing resources
6. **Cleanup**: Update lock status and cleanup old entries

### Manual Workflow Options

| Input | Options | Description |
|-------|---------|-------------|
| Environment | `dev`, `stag`, `prod` | Target environment |
| Terraform Action | `init`, `plan`, `apply`, `destroy` | Operation to perform |
| AWS Region | `us-west-1 (dev)`, `us-west-2 (stag)`, `us-east-1 (prod)` | Target region |

## 🔒 Security Features

### State Management
- **Remote State**: Stored in S3 with versioning
- **State Locking**: DynamoDB prevents concurrent modifications
- **Encryption**: Server-side encryption for state files
- **Access Control**: Bucket policies restrict public access

### Custom Lock Management

The `manage-state-lock.sh` script provides:
- Lock creation with metadata
- Lock status checking
- Automatic cleanup of old locks
- Audit trail in DynamoDB

```bash
# Create lock
./scripts/manage-state-lock.sh dev create

# Check lock status
./scripts/manage-state-lock.sh dev check

# Release lock
./scripts/manage-state-lock.sh dev release
```

## 🌍 Multi-Environment Support

### Environment Isolation

| Environment | Region | Purpose |
|-------------|--------|---------|
| `dev` | us-west-1 | Development and testing |
| `stag` | us-west-2 | Staging and pre-production |
| `prod` | us-east-1 | Production workloads |

### Resource Naming Convention

```
ind-{environment}-{resource-name}-{random-suffix}
```

Examples:
- `ind-dev-data-test-first-abc123`
- `ind-prod-user-data-xyz789`

## 📊 Monitoring and Observability

### State Lock Tracking

The system tracks all state operations in DynamoDB:

```json
{
  "LockID": "terraform-dev-1234567890",
  "ProcessID": "github-actions-123-1234567890",
  "Environment": "dev",
  "Status": "ACTIVE",
  "Created": "2024-01-01T12:00:00Z"
}
```

### Workflow Outputs

- S3 bucket listings
- DynamoDB lock status
- Resource import results
- Terraform plan/apply outputs

## 🛠️ Troubleshooting

### Common Issues

#### State Lock Issues
```bash
# Check current locks
./scripts/manage-state-lock.sh dev check

# Force release if needed
./scripts/manage-state-lock.sh dev release
```

#### Resource Import Conflicts
The workflow automatically imports existing resources:
- S3 buckets
- DynamoDB tables
- IAM roles

#### Workflow Not Triggering
1. Ensure workflow file exists in target branch
2. Check GitHub Actions permissions
3. Verify secrets are configured

### Debug Commands

```bash
# List S3 state objects
aws s3 ls s3://ind-tfstate-bucket/terraform/

# Check DynamoDB locks
aws dynamodb scan --table-name ind-tfstate-lock

# Verify bucket exists
aws s3api head-bucket --bucket ind-tfstate-bucket
```

## 📋 Best Practices

### Development Workflow
1. Create feature branch
2. Make infrastructure changes
3. Test in `dev` environment
4. Create pull request (triggers plan)
5. Review and merge
6. Deploy to `stag` for testing
7. Deploy to `prod` after approval

### Security Guidelines
- Never commit AWS credentials
- Use least privilege IAM policies
- Enable MFA for production deployments
- Regularly rotate access keys
- Monitor CloudTrail logs

### State Management
- Always use remote state
- Enable state file versioning
- Implement state locking
- Regular state file backups
- Monitor state file access

## 🔄 Maintenance

### Regular Tasks
- Update Terraform version in workflow
- Rotate AWS credentials
- Clean up old state lock entries
- Review and update IAM policies
- Monitor resource costs

### Backup Strategy
- State files: Automatic S3 versioning
- DynamoDB: Point-in-time recovery enabled
- Code: Git repository with multiple remotes

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in development environment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Need Help?** Check the troubleshooting section or create an issue in the repository.