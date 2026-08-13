terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.59.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"
}