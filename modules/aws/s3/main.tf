
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket" "this" {
  bucket        = "ind-${var.environment}-${var.bucket_name}-${random_string.bucket_suffix.result}"
  force_destroy = var.force_destroy

  tags = merge({
    Name = "ind-${var.environment}-${var.bucket_name}-${random_string.bucket_suffix.result}"
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