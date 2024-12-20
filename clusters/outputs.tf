output "console_domain" {
  value       = module.ec2.console_public_dns
  description = "The console endpoint"
}
