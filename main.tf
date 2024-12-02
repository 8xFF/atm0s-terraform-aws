terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source     = "./modules/vpc"
  env        = var.env
  cidr_block = var.vpc_cidr_block
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "8xff-${var.env}-cluster"
}

module "ec2" {
  source                    = "./modules/ec2"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_id          = module.vpc.subnet_public_ids
  public_security_group_id  = module.vpc.public_security_group_id
  number_standard_instances = 1
  number_media_instances    = 1
  standard_instance_type    = var.standard_instance_type
  media_instance_type       = var.media_instance_type
  ecs_cluster_name          = aws_ecs_cluster.ecs_cluster.name
  keypair_name              = var.keypair_name
}
