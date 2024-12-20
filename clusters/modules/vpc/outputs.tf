output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of VPC"
}

output "subnet_public_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "The IDs of public subnets"
}

output "subnet_public_first_three_octets" {
  value = [
    for subnet in aws_subnet.public_subnets :
    join(".", slice(split(".", subnet.cidr_block), 0, 3))
  ]
  description = "The CIDR blocks of public subnets"
}

output "public_security_group_id" {
  value       = aws_security_group.main.id
  description = "The ID of public security group"
}
