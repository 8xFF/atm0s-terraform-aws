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
}

module "iam" {
  source = "./modules/iam"
  env    = var.env
}

module "vpc" {
  source     = "./modules/vpc"
  env        = var.env
  cidr_block = var.vpc_cidr_block
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "8xff-${var.env}-cluster"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

module "console_service" {
  source                 = "./modules/services/console"
  keypair_name           = var.keypair_name
  instance_type          = var.standard_instance_type
  container_image        = var.container_image
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.subnet_public_ids
  security_group_id      = module.vpc.public_security_group_id
  ec2_iam_profile        = module.iam.ecs_instance_role_profile
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}
