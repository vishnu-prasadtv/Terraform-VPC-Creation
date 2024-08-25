
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

  required_version = ">= 1.9.3"
}

provider "aws" {
  region  = "us-west-2"
}
