variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Region mapping based on environment
locals {
  region_map = {
    dev  = "us-west-1"
    stag = "us-west-1" 
    prod = "us-west-2"
  }
  deployment_region = local.region_map[var.environment]
}

variable "environment" {
  description = "The environment to deploy (dev, stag, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "stag", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stag, prod."
  }
}