terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      #source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  cloud {
    organization = "iheanyi1989"
    workspaces {
      name = "iondl"
    }
  }
}
