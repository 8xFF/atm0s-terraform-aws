variable "env" {
  type        = string
  description = "The environment"
}

variable "aws_region" {
  type        = string
  description = "The aws region"
}

variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of subnet"
}

variable "ec2_ami" {
  type        = string
  description = "The AMI ID for EC2 instance"
}

variable "security_group_id" {
  type        = string
  description = "The ID of security group"
}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair"
}

variable "ec2_iam_profile" {
  type        = string
  description = "The IAM profile"
}

variable "standard_instance_type" {
  type        = string
  description = "The instance type"
}

variable "media_instance_type" {
  type        = string
  description = "The instance type"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of ECS cluster"
}

variable "is_primary_cluster" {
  type        = bool
  description = "Primary cluster"
}
