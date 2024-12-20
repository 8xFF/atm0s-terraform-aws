variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
  default     = "dev"
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

variable "container_image" {
  type        = string
  description = "The container image"
  default     = "ghcr.io/8xff/atm0s-media-server:master"
}

variable "cluster_secret" {
  type        = string
  description = "The secret for the cluster"
  default     = "insecure"
}
