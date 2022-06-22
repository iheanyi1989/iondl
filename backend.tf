terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19"
    }
  }
  cloud {
    organization = "iheanyi1989"
    workspaces {
      name = "iondl"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "Dev"
      createdby   = "Iheanyi"


    }
  }
}



