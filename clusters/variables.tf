variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
}

variable "ecs_instance_role_profile" {
  type        = string
  description = "The role profile"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "The execution role arn"
}

variable "cidr_block" {
  type        = string
  description = "Cidr block for vpc"
}

variable "zone_id" {
  type        = string
  description = "value of zone id"
}

variable "standard_instance_type" {
  type        = string
  description = "The standard instance type"
}

variable "media_instance_type" {
  type        = string
  description = "The media instance type"
}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair"
}

variable "container_image" {
  type        = string
  description = "The container image"
}

variable "cluster_secret" {
  type        = string
  description = "The secret for the cluster"
  default     = "insecure"
}

variable "console_endpoint" {
  type        = string
  description = "The console endpoint"
  nullable    = true
}

variable "is_primary_cluster" {
  type        = bool
  description = "Is this the primary cluster"
  default     = false
}
