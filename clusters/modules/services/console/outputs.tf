output "console_public_ip" {
  value       = aws_eip.console_eip.public_ip
  description = "The public IP of console instance"
}
