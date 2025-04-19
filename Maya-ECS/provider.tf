provider "aws" {
  region = "eu-north-1"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}