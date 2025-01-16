terraform {

  required_providers {

    aws = {
      region = "us-east-1"
      source  = "hashicorp/aws"
      version = "~> 5.69"
    }

  }

  required_version = ">= 1.8.3"

  backend "s3" {
    bucket = "backends3awsterraform"
    key    = "terraformrds.tfstate"
    region = "us-east-1"
  }

}