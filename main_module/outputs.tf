# S3 outputs
output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}

# SQS outputs
output "queue_url" {
  value = module.sqs_queue.queue_url
}

output "queue_arn" {
  value = module.sqs_queue.queue_arn
}

# DynamoDB outputs
output "dynamodb_table_name" {
  value = module.dynamodb_table.table_name
}

output "dynamodb_table_arn" {
  value = module.dynamodb_table.table_arn
}