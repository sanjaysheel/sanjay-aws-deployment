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
  description = "The environment for the S3 bucket (dev, prod, etc.)"
  type        = string
  default     = "dev"
}
