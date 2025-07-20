terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket         = "ind-tfstate-bucket"
    region         = "us-east-1"
    dynamodb_table = "ind-tfstate-lock"
    encrypt        = true
  }
}