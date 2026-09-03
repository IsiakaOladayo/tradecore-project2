# =========================================================
# ECS CLUSTER
# =========================================================

output "ecs_cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.application.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.application.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.application.name
}


# =========================================================
# ECS SERVICE
# =========================================================

output "ecs_service_id" {
  description = "ID of the ECS service."
  value       = aws_ecs_service.application.id
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.application.name
}


# =========================================================
# ECS TASK DEFINITION
# =========================================================

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.application.arn
}

output "ecs_task_definition_family" {
  description = "Family name of the ECS task definition."
  value       = aws_ecs_task_definition.application.family
}


# =========================================================
# IAM
# =========================================================

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.arn
}


# =========================================================
# SECURITY GROUP
# =========================================================

output "ecs_security_group_id" {
  description = "Security group ID used by ECS tasks."
  value       = local.application_security_group_id
}


# =========================================================
# CLOUDWATCH
# =========================================================

output "ecs_log_group_name" {
  description = "CloudWatch log group used by ECS."
  value       = aws_cloudwatch_log_group.application.name
}

output "ecs_log_group_arn" {
  description = "ARN of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.application.arn
}
