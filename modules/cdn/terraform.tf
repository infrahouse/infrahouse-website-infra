terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11"
      configuration_aliases = [
        aws.ue1 # AWS provider in us-east-1
      ]
    }
  }
}
