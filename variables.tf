variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment to deploy (dev, stagrod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "stag"prod"], var.environment)
    error_message = "Environment must be one of: dev, stagrod."
  }
}
