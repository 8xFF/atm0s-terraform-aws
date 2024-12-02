variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "The ID of public subnet"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of ECS cluster"
}

variable "public_security_group_id" {
  type        = string
  description = "The ID of public security group"

}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair"
}

variable "standard_instance_type" {
  type        = string
  description = "The standard instance type"
}

variable "media_instance_type" {
  type        = string
  description = "The media instance type"
}

variable "number_standard_instances" {
  type        = number
  description = "The number of standard instances"
}

variable "number_media_instances" {
  type        = number
  description = "The number of media instances"
}
