# output "bucket_name" {
#   value = aws_s3_bucket.this.bucket
# }

# output "bucket_arn" {
#   value = aws_s3_bucket.this.arn
# }

# output "bucket_domain_name" {
#   value = aws_s3_bucket.this.bucket_domain_name
# }
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}
