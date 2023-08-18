provider "aws" {
  alias  = "aws-uw1"
  region = "us-west-1"
  assume_role {
    role_arn = var.tf_admin_arn
  }
  default_tags {
    tags = {
      "created_by" : var.repo_name
      "environment" : var.environment
    }
  }
}

provider "aws" {
  alias  = "aws-ue1"
  region = "us-east-1"
  assume_role {
    role_arn = var.tf_admin_arn
  }
  default_tags {
    tags = {
      "created_by" : var.repo_name
      "environment" : var.environment
    }
  }
}
