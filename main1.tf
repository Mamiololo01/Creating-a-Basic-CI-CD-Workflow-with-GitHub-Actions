terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.55.0"
    }
  }
  backend "s3" {
    bucket         = "gitactioncicd2023"
    key            = "terraform/terraform.tfstate"
    dynamodb_table = "terraform_lock"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "sgitactioncicd2023"

  tags = {
    Name        = "GitHub Actions Bucket"
    Environment = "Demo"
  }
}
