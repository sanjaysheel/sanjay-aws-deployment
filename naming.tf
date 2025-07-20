locals {
  # Common prefix for all resources
  prefix = "ind"
  
  # Resource naming convention
  name_prefix = "${local.prefix}-${var.environment}"
  
  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AWS-Deployment"
  }
}