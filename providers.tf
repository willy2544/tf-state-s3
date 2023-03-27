terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "sandbox"
      Owner       = "willy2544"
      Repo        = "tf-vpc"
    }
  }
}