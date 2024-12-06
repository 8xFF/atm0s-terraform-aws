output "main_cluster_console_ip" {
  value       = module.main_cluster.console_public_ip
  description = "The console endpoint of the main cluster"
}

output "main_cluster_alb_dns_name" {
  value       = module.main_cluster.alb_dns_name
  description = "The DNS name of the main cluster ALB"
}
