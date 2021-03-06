terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.35"
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

provider "snowflake" {
  role     = var.role
  username = var.username
  account  = var.account
  password = var.password
}


