output "gateway_public_ip" {
  value       = aws_eip.gateway_eip.public_ip
  description = "The public IP of console instance"
}

output "gateway_instance_id" {
  value       = aws_instance.gateway_instance.id
  description = "The ID of gateway instance"
}
