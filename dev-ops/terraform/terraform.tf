terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.3"
    }
  }
}

provider "aws" {
  region  = var.AWS_REGION
  profile = var.AWS_PROFILE
}
