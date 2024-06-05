#### local stack provider info
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    secretsmanager  = "http://localstack:4566"
    lambda          = "http://localstack:4566"
    rds             = "http://localstack:4566"
    ec2             = "http://localstack:4566"
    kms             = "http://localstack:4566"
    iam             = "http://localstack:4566"
  }
}