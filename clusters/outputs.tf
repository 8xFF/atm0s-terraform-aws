output "console_domain" {
  value       = module.ec2.console_public_dns
  description = "The console endpoint"
}

output "gateway_domain" {
  value       = module.ec2.gateway_public_dns
  description = "The of the gateway domain"
}
