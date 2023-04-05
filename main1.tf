terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.55.0"
    }
  }
  backend "s3" {
    bucket         = "<Backend State S3 Bucket Name>"
    key            = "terraform/terraform.tfstate"
    dynamodb_table = "<Dependency Lock DynamoDB Table Name>"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "<Terraform S3 Bucket Name>"

  tags = {
    Name        = "GitHub Actions Bucket"
    Environment = "Demo"
  }
}
