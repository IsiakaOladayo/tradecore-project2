# =========================================================
# TRADECORE - ROOT OUTPUTS
# =========================================================

# ---------------------------------------------------------
# NETWORKING
# ---------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

# ---------------------------------------------------------
# ALB
# ---------------------------------------------------------

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Route53 zone ID of the ALB."
  value       = module.alb.alb_zone_id
}

# ---------------------------------------------------------
# ECS
# ---------------------------------------------------------

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.ecs.ecs_service_name
}

# ---------------------------------------------------------
# RDS
# ---------------------------------------------------------

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.db_port
}

# ---------------------------------------------------------
# COGNITO
# ---------------------------------------------------------

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool."
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "ID of the Cognito User Pool Client."
  value       = module.cognito.client_id
}

# ---------------------------------------------------------
# AMPLIFY
# ---------------------------------------------------------

output "amplify_app_id" {
  description = "ID of the Amplify app."
  value       = module.amplify.app_id
}

output "amplify_default_domain" {
  description = "Default domain of the Amplify app."
  value       = module.amplify.default_domain
}

# ---------------------------------------------------------
# IAM (OIDC + GITHUB ACTIONS)
# ---------------------------------------------------------

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions."
  value       = module.iam.github_actions_role_arn
}

output "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions."
  value       = module.iam.github_actions_role_name
}

# ---------------------------------------------------------
# SECRETS MANAGER
# ---------------------------------------------------------

output "secret_arns" {
  description = "Map of Secrets Manager secret ARNs."
  value       = module.secrets_manager.secret_arns
}
