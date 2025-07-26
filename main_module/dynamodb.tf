module "dynamodb_table" {
  source      = "../modules/aws/dynamodb"
  table_name  = "user-data"
  environment = var.environment
  hash_key    = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = local.common_tags
}