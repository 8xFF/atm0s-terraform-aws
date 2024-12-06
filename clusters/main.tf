terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
  }
}


module "iam" {
  source = "./modules/iam"
  env    = var.env
}

module "vpc" {
  source     = "./modules/vpc"
  env        = var.env
  cidr_block = "10.0.0.0/16"
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

data "aws_region" "current" {}



module "console_service" {
  source                 = "./modules/services/console"
  zone_id                = var.zone_id
  keypair_name           = var.keypair_name
  instance_type          = var.standard_instance_type
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.subnet_public_ids[0]
  security_group_id      = module.vpc.public_security_group_id
  ec2_iam_profile        = module.iam.ecs_instance_role_profile
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}

module "gateway_service" {
  source                 = "./modules/services/gateway"
  zone_id                = var.zone_id
  keypair_name           = var.keypair_name
  instance_type          = var.standard_instance_type
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.subnet_public_ids[0]
  security_group_id      = module.vpc.public_security_group_id
  ec2_iam_profile        = module.iam.ecs_instance_role_profile
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  console_endpoint       = "http://${module.console_service.console_public_ip}:8080"
}

module "connector_service" {
  source                 = "./modules/services/connector"
  zone_id                = var.zone_id
  keypair_name           = var.keypair_name
  instance_type          = var.standard_instance_type
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.subnet_public_ids[0]
  security_group_id      = module.vpc.public_security_group_id
  ec2_iam_profile        = module.iam.ecs_instance_role_profile
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  gateway_endpoint       = "http://${module.gateway_service.gateway_public_ip}:3000"
}

module "media_service" {
  source                 = "./modules/services/media"
  zone_id                = var.zone_id
  keypair_name           = var.keypair_name
  instance_type          = var.media_instance_type
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.subnet_public_ids[0]
  security_group_id      = module.vpc.public_security_group_id
  ec2_iam_profile        = module.iam.ecs_instance_role_profile
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  gateway_endpoint       = "http://${module.gateway_service.gateway_public_ip}:3000"
}
