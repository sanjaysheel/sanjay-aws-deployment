# Terraform State Management Setup

This directory contains the Terraform configuration to set up the S3 bucket and DynamoDB table for remote state management.

## Setup Instructions

1. Run the following commands to create the state bucket and lock table:

```bash
cd setup
terraform init
terraform apply
```

2. Once the state bucket and DynamoDB table are created, you can use the backend configuration in the main project.

## State Storage Structure

The state files will be stored in the following structure:

- `terraform/dev/terraform.tfstate` - Dev environment state
- `terraform/staging/terraform.tfstate` - Staging environment state
- `terraform/prod/terraform.tfstate` - Production environment state