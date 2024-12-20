output "console_public_dns" {
  value       = length(aws_instance.console_instance) > 0 ? aws_instance.console_instance[0].public_dns : null
  description = "The public dns of console instance"
}

output "gateway_public_dns" {
  value       = aws_instance.gateway_instance.public_dns
  description = "The public dns of gateway instance"
}

output "media_autoscale_group_arn" {
  value       = aws_autoscaling_group.media_ec2_autoscale_group.arn
  description = "The arn of media autoscale group"
}
