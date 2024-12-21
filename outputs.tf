output "main_cluster_console_domain" {
  value       = module.main_cluster.console_domain
  description = "The console endpoint of the main cluster"
}

output "main_cluster_gateway_domain" {
  value       = module.main_cluster.gateway_domain
  description = "The gateway domain of the main cluster"
}

output "sub_cluster_1_console_domain" {
  value       = module.sub_cluster_1.console_domain
  description = "The console endpoint of the sub cluster 1"
}
