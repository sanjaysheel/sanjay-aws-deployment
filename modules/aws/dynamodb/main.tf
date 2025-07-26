resource "aws_dynamodb_table" "this" {
  name           = "ind-${var.environment}-${var.table_name}"
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      attribute_name = var.ttl_attribute_name
      enabled        = var.ttl_enabled
    }
  }

  tags = merge({
    Name = "ind-${var.environment}-${var.table_name}"
  }, var.tags)
  
  lifecycle {
    ignore_changes = [billing_mode, hash_key, range_key, attribute]
  }
}