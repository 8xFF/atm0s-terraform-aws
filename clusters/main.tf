terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
  }
}

module "vpc" {
  source     = "./modules/vpc"
  env        = var.env
  cidr_block = var.cidr_block
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

module "ec2" {
  source                 = "./modules/ec2"
  env                    = var.env
  keypair_name           = var.keypair_name
  standard_instance_type = var.standard_instance_type
  media_instance_type    = var.media_instance_type
  is_primary_cluster     = var.is_primary_cluster
  ec2_iam_profile        = var.ecs_instance_role_profile
  ec2_ami                = data.aws_ami.amazon_linux_2.id
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.subnet_public_ids
  security_group_id      = module.vpc.public_security_group_id
}

module "console_service" {
  source                 = "./modules/services/console"
  env                    = var.env
  zone_id                = var.zone_id
  cluster_secret         = var.cluster_secret
  container_image        = var.container_image
  ecs_execution_role_arn = var.ecs_execution_role_arn
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  subnet_cidr_prefix     = module.vpc.subnet_public_first_three_octets[0]
}

module "gateway_service" {
  source                 = "./modules/services/gateway"
  env                    = var.env
  zone_id                = var.zone_id
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ecs_execution_role_arn = var.ecs_execution_role_arn
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  console_endpoint       = var.console_endpoint == null && var.is_primary_cluster ? module.ec2.console_public_dns : var.console_endpoint
  subnet_cidr_prefix     = module.vpc.subnet_public_first_three_octets[0]

  depends_on = [module.console_service]
}


module "connector_service" {
  source                 = "./modules/services/connector"
  env                    = var.env
  zone_id                = var.zone_id
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ecs_execution_role_arn = var.ecs_execution_role_arn
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  gateway_endpoint       = module.ec2.gateway_public_dns
  subnet_cidr_prefix     = module.vpc.subnet_public_first_three_octets[0]

  depends_on = [module.gateway_service]
}

module "media_service" {
  source                 = "./modules/services/media"
  env                    = var.env
  zone_id                = var.zone_id
  container_image        = var.container_image
  cluster_secret         = var.cluster_secret
  ecs_execution_role_arn = var.ecs_execution_role_arn
  aws_region             = data.aws_region.current.name
  ecs_cluster_name       = aws_ecs_cluster.ecs_cluster.name
  gateway_endpoint       = module.ec2.gateway_public_dns
  autoscale_group_arn    = module.ec2.media_autoscale_group_arn
  subnet_cidr_prefix     = module.vpc.subnet_public_first_three_octets[0]

  depends_on = [module.gateway_service]
}
