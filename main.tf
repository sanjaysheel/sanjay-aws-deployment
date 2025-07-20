module "s3_bucket" {
  source      = "./modules/aws/s3"               # Path to the S3 module
  bucket_name = "ind-dp-nyc-taxi-data-pipelines" # Your desired bucket name
  environment = var.environment                  # Use an environment variable (e.g., dev, prod)
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
