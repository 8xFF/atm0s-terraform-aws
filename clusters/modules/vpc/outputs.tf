output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of VPC"
}

output "subnet_public_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "The IDs of public subnets"
}

output "subnet_private_ids" {
  value       = aws_subnet.private_subnets.*.id
  description = "The IDs of private subnets"
}

output "public_security_group_id" {
  value       = aws_security_group.main.id
  description = "The ID of public security group"
}
