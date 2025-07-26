module "s3_bucket" {
  source        = "../modules/aws/s3" # Path to the S3 module
  bucket_name   = "data-test-first"   # Short base name, unique suffix is added in the module
  environment   = var.environment     # Use an environment variable (e.g., dev, prod)
  tags          = local.common_tags   # Pass common tags to the module
  force_destroy = true                # Allow deletion of non-empty bucket
}
