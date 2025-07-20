module "s3_bucket" {
  source      = "./modules/aws/s3"      # Path to the S3 module
  bucket_name = "nyc-taxi-data"         # Your desired bucket name suffix
  environment = var.environment         # Use an environment variable (e.g., dev, prod)
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
