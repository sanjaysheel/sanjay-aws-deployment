
output "dev_sqs_url" {
  value = module.sqs_dev.sqs_queue_url
}

output "prod_sqs_url" {
  value = module.sqs_prod.sqs_queue_url
}
output "dev_sqs_arn" {
  value = module.sqs_dev.sqs_queue_arn
}

output "prod_sqs_arn" {
  value = module.sqs_prod.sqs_queue_arn
}


output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
