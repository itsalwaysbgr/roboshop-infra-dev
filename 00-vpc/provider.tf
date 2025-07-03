terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }
  backend "s3" {
    bucket       = "86s-remote-state-dev"
    key          = "roboshop-dev-vpc" # this is what key will get generated in dynamodb in AWS
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
    #dynamodb_table = "86s-remote-state" # depreicated so need to use dynamodb s3 wil natively store the state file
  }
}

provider "aws" {
  # configuration  
  region = "us-east-1"
}

