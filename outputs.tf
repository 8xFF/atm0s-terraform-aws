output "console_public_ip" {
  value       = module.console_service.console_public_ip
  description = "The public IP of console instance"
}
