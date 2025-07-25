# variable "bucket_name" {
#   description = "The name of the S3 bucket"
#   type        = string
# }

# variable "environment" {
#   description = "The environment (dev, stag, prod)"
#   type        = string
# }

# variable "tags" {
#   description = "A map of tags to assign to the resource"
#   type        = map(string)
#   default     = {}
# }

# variable "force_destroy" {
#   description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
#   type        = bool
#   default     = false
# }
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "acl" {
  description = "The canned ACL to apply"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "A map of tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
