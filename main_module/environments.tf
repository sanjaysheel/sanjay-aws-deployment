locals {
  allowed_environments = ["dev", "stag", "prod"]
}

# Create environment-specific IAM roles
resource "aws_iam_role" "environment_role" {
  name = "environment-${var.environment}-role"

  assume_role_policy = file("../modules/template/iam_assume_role_policy.json")

  tags = {
    Environment = var.environment
  }
}