module "sqs_dev" {
  source        = "./modules/sqs"
  queue_name    = "dev-queue"
  fifo_queue    = false
  delay_seconds = 0
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

module "sqs_prod" {
  source                      = "./modules/sqs"
  queue_name                  = "prod-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0
  tags = {
    Environment = "prod"
    Project     = "example"
  }
}
