resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  effective_env      = var.environment == "stag" ? "dev" : var.environment
  unique_bucket_name = "ind-${local.effective_env}-${var.bucket_name}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.unique_bucket_name
  force_destroy = var.force_destroy

  tags = merge({
    Name = "ind-${local.effective_env}-${var.bucket_name}"
  }, var.tags)
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}