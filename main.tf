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

provider "aws" {
  region = "eu-central-1"
  alias  = "frankfurt"
}

module "iam" {
  source = "./common/iam"
  env    = var.env

  providers = {
    aws = aws.singapore
  }
}

module "main_cluster" {
  source                    = "./clusters"
  zone_id                   = "0"
  env                       = var.env
  keypair_name              = var.keypair_name
  container_image           = var.container_image
  media_instance_type       = var.media_instance_type
  standard_instance_type    = var.standard_instance_type
  cidr_block                = "10.0.0.0/16"
  console_endpoint          = null
  is_primary_cluster        = true
  ecs_execution_role_arn    = module.iam.ecs_execution_role_arn
  ecs_instance_role_profile = module.iam.ecs_instance_role_profile
  depends_on                = [module.iam]

  providers = {
    aws = aws.singapore
  }
}

module "sub_cluster_1" {
  source                    = "./clusters"
  zone_id                   = "1"
  env                       = var.env
  keypair_name              = var.keypair_name
  container_image           = var.container_image
  media_instance_type       = var.media_instance_type
  standard_instance_type    = var.standard_instance_type
  cidr_block                = "10.1.0.0/16"
  console_endpoint          = module.main_cluster.console_domain
  is_primary_cluster        = false
  ecs_execution_role_arn    = module.iam.ecs_execution_role_arn
  ecs_instance_role_profile = module.iam.ecs_instance_role_profile

  depends_on = [module.main_cluster]
  providers = {
    aws = aws.frankfurt
  }
}
