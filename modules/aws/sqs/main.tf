resource "aws_sqs_queue" "this" {
  name = "ind-${var.environment}-${var.queue_name}"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size          = var.max_message_size
  delay_seconds             = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  tags = merge({
    Name = "ind-${var.environment}-${var.queue_name}"
  }, var.tags)
}