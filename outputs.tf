output "main_cluster_console_ip" {
  value       = module.main_cluster.console_public_ip
  description = "The console endpoint of the main cluster"
}
