variable "env" {
  type        = string
  description = "The environment"
}

variable "zone_id" {
  type        = string
  description = "value of zone id"
}

variable "aws_region" {
  type        = string
  description = "The aws region"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of ECS cluster"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "The ARN of ECS execution role"

}

variable "container_image" {
  type        = string
  description = "The container image"
}

variable "console_endpoint" {
  type        = string
  description = "The console endpoint"
}

variable "cluster_secret" {
  type        = string
  description = "The secret for the cluster"
  default     = "insecure"
}

variable "subnet_cidr_prefix" {
  type        = string
  description = "The subnet cidr prefix"
}
