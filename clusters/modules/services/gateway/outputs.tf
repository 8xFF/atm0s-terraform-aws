output "gateway_public_ip" {
  value       = aws_eip.gateway_eip.public_ip
  description = "The public IP of console instance"
}
