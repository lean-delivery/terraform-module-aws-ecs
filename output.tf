output "ecs_service_iam_role_arn" {
  value = element(
    concat(
      aws_iam_role.ecs-service.*.arn,
      aws_iam_role.ecs-service-ec2.*.arn,
      [""],
    ),
    0,
  )
  description = "ARN fo created ECS service"
}

output "ecs_service_iam_role_name" {
  value = element(
    concat(
      aws_iam_role.ecs-service.*.name,
      aws_iam_role.ecs-service-ec2.*.name,
      [""],
    ),
    0,
  )
  description = "Name of IAM role that attached to ECS service"
}

output "ecs_task_execution_iam_role_arn" {
  value       = aws_iam_role.ecs-task-execution.arn
  description = "Arn of IAM role that attached to ECS task execution"
}

output "ecs_task_execution_iam_role_name" {
  value       = aws_iam_role.ecs-task-execution.name
  description = "Name of IAM role that attached to ECS task execution"
}

output "ecs_task_execution_container_cpu" {
  value       = var.container_cpu
  description = "Amount of cpu used by the task"
}

output "ecs_task_execution_container_memory" {
  value       = var.container_memory
  description = "Amount of memory used by the task"
}

output "ecs_cluster_arn" {
  value       = local.ecs_cluster_arn
  description = "ECS cluster ARN"
}

output "ecs_cluster_id" {
  value       = local.ecs_cluster_id
  description = "ECS cluster ID"
}

output "ecs_cluster_name" {
  value       = local.ecs_cluster_name
  description = "ECS cluster name"
}

output "security_group_description" {
  description = "The description of the security group."
  value       = module.security-group.this_security_group_description
}

output "security_group_id" {
  description = "The ID of the security group."
  value       = module.security-group.this_security_group_id
}

output "security_group_name" {
  description = "The name of the security group."
  value       = module.security-group.this_security_group_name
}

output "security_group_owner_id" {
  description = "The owner ID."
  value       = module.security-group.this_security_group_owner_id
}

output "security_group_vpc_id" {
  description = "The VPC ID."
  value       = module.security-group.this_security_group_vpc_id
}

