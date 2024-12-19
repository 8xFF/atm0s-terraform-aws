terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "singapore"
}

module "main_cluster" {
  source                 = "./clusters"
  zone_id                = "0"
  env                    = var.env
  keypair_name           = var.keypair_name
  container_image        = var.container_image
  media_instance_type    = var.media_instance_type
  standard_instance_type = var.standard_instance_type
  console_endpoint       = null

  providers = {
    aws = aws.singapore
  }
}
