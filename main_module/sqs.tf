module "sqs_queue" {
  source      = "../modules/aws/sqs"
  queue_name  = "data-queue"
  environment = var.environment
  tags        = local.common_tags
}