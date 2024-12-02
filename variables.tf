variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
  default     = "dev"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC's CIDR block"
  default     = "10.0.0.0/16"
}

variable "standard_instance_type" {
  type        = string
  description = "The standard instance type"
  default     = "t2.nano"
}

variable "media_instance_type" {
  type        = string
  description = "The media instance type"
  default     = "t3.micro"
}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair"
}
