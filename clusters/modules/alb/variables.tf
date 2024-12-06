variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
}

variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID of subnet"
}

variable "security_group_id" {
  type        = string
  description = "The ID of security group"
}

variable "gateway_instance_id" {
  type        = string
  description = "The ID of gateway instance"
}
