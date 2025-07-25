# module "s3_bucket" {
#   source      = "../modules/aws/s3"              # Path to the S3 module
#   bucket_name = "${var.environment}-data-test-1" # Environment-specific bucket name suffix
#   environment = var.environment                  # Use an environment variable (e.g., dev, prod)
#   tags        = local.common_tags                # Pass common tags to the module
#   force_destroy = true                           # Allow deletion of non-empty bucket
# }

# output "bucket_name" {
#   value = module.s3_bucket.bucket_name
# }

# output "bucket_arn" {
#   value = module.s3_bucket.bucket_arn
# }
module "my_s3_bucket" {
  source      = "./modules/s3"
  bucket_name = "my-unique-bucket-name"
  acl         = "private"
  tags = {
    Environment = "Production"
    Project     = "Terraform"
  }
}

output "s3_bucket_name" {
  value = module.my_s3_bucket.bucket_name
}
