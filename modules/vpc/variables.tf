variable "env" {
  type        = string
  description = "Current state of project: dev, prod, stage..."
}

variable "cidr_block" {
  type        = string
  description = "The VPC's CIDR block"
}
