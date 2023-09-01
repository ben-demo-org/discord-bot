terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    required_version = ">= 1.5.0"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}