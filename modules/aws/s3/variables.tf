variable "bucket_name" {
  description = "The name suffix for the S3 bucket (will be prefixed with ind-{environment}-)"
  type        = string
  default     = "data-bucket"
}

variable "bucket_acl" {
  description = "The access control list (ACL) for the S3 bucket"
  type        = string
  default     = "private"
}

variable "environment" {
  description = "The environment to deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
