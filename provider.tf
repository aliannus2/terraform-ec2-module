# Specifies the version constraints for Terraform and the AWS provider.
# This ensures that the code is run with compatible versions.
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Specifies the provider to use, in this case, AWS.
# It's a good practice to configure the provider in a separate file.
provider "aws" {
  region = "us-east-1" # You can change this to your desired AWS region.
}
