provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "../modules/vpc"
  env_name = "dev"
}

# Other resources (e.g., EC2, S3, RDS)
resource "aws_instance" "dev_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name        = "dev-instance"
    Environment = "dev"
  }
}
