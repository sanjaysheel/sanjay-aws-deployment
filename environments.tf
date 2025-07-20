locals {
  allowed_environments = ["dev", "staging", "prod"]
  
  # Validate environment
  validate_env = (
    contains(local.allowed_environments, var.environment) 
    ? null 
    : file("ERROR: Environment must be one of: ${join(", ", local.allowed_environments)}")
  )
}

# Create environment-specific IAM roles
resource "aws_iam_role" "environment_role" {
  name = "environment-${var.environment}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = var.environment
  }
}