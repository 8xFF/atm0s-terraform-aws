output "console_public_ip" {
  value       = module.console_service.console_public_ip
  description = "The public IP of console instance"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The DNS name of ALB"
}
