output "ecs_instance_role_profile" {
  value = aws_iam_instance_profile.ecs_instance_role_profile.name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
