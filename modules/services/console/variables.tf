variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "subnet_id" {
  type        = string
  description = "The ID of subnet"
}

variable "ec2_ami" {
  type        = string
  description = "The AMI ID for EC2 instance"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of ECS cluster"
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

variable "ecs_execution_role_arn" {
  type        = string
  description = "The ARN of ECS execution role"

}

variable "instance_type" {
  type        = string
  description = "The instance type"
}

variable "container_image" {
  type        = string
  description = "The container image"
}
