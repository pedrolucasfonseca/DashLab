terraform {
    backend "s3" {
        bucket = "dashlab-terraform-state"
        key = "prod/terraform.tfstate"
        region = "us-east-1"
        use_lockfile = true
        encrypt = true
    }

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.region
}