variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
}

variable "zone_id" {
  type        = number
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
