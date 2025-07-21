resource "aws_s3_bucket" "this" {
  bucket = "ind-${var.environment}-${var.bucket_name}"

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

resource "aws_s3_object" "example" {
  bucket  = aws_s3_bucket.this.bucket
  key     = "example_file.txt"
  content = "This is a test file content"
}
