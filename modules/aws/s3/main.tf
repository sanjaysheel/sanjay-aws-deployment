resource "aws_s3_bucket" "this" {
  bucket = "ind-${var.environment}-${var.bucket_name}"
  force_destroy = var.force_destroy

  tags = merge({
    Name = "ind-${var.environment}-${var.bucket_name}"
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

# Temporarily removed to allow bucket deletion
# resource "aws_s3_bucket_lifecycle_configuration" "this" {
#   bucket = aws_s3_bucket.this.id
#   rule {
#     id     = "delete_all"
#     status = "Enabled"
#     filter {
#       prefix = ""
#     }
#     expiration {
#       days = 1
#     }
#     noncurrent_version_expiration {
#       noncurrent_days = 1
#     }
#     abort_incomplete_multipart_upload {
#       days_after_initiation = 1
#     }
#   }
# }

# resource "aws_s3_object" "example" {
#   bucket  = aws_s3_bucket.this.bucket
#   key     = "example_file.txt"
#   content = "This is a test file content"
# }
