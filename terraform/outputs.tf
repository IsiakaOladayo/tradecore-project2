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

# ---------------------------------------------------------
# ACM (CERTIFICATE) - ENABLED LATER
# ---------------------------------------------------------

# output "acm_certificate_arn" {
#   description = "ARN of the ACM certificate."
#   value       = module.acm.certificate_arn
# }

# output "acm_domain_validation_options" {
#   description = "Domain validation options for ACM certificate."
#   value       = module.acm.domain_validation_options
# }

# ---------------------------------------------------------
# STATE (S3 + DynamoDB)
# ---------------------------------------------------------

output "state_bucket_name" {
  description = "Name of the S3 state bucket."
  value       = module.state.bucket_name
}

output "state_dynamodb_table_name" {
  description = "Name of the DynamoDB lock table."
  value       = module.state.dynamodb_table_name
}

# ---------------------------------------------------------
# DEPLOYMENT SUMMARY
# ---------------------------------------------------------

output "deployment_summary" {
  description = "Summary of all service values for deployment."
  value = {
    AWS_REGION          = var.aws_region
    ECR_REPOSITORY      = module.ecr.repository_url
    ECS_CLUSTER         = module.ecs.ecs_cluster_name
    ECS_SERVICE         = module.ecs.ecs_service_name
    ECS_TASK_DEFINITION = module.ecs.ecs_task_definition_family
    AWS_DEPLOY_ROLE_ARN = module.iam.github_actions_role_arn
    AMPLIFY_APP_ID      = module.amplify.app_id
    PRODUCTION_URL      = module.amplify.default_domain
    # CERTIFICATE_ARN   = module.acm.certificate_arn  # Enable later with duckdns.org
  }
}
