resource "aws_sqs_queue" "this" {
  name                        = var.queue_name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  delay_seconds               = var.delay_seconds
  maximum_message_size        = var.maximum_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  visibility_timeout_seconds  = var.visibility_timeout_seconds

  tags = var.tags
}

output "sqs_queue_url" {
  value = aws_sqs_queue.this.id
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.this.arn
}