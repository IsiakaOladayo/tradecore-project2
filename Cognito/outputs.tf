output "user_pool_id" {
  description = "ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.application.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.application.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool."
  value       = aws_cognito_user_pool.application.endpoint
}

output "user_pool_creation_date" {
  description = "Creation date of the Cognito User Pool."
  value       = aws_cognito_user_pool.application.creation_date
}

output "user_pool_last_modified_date" {
  description = "Last modified date of the Cognito User Pool."
  value       = aws_cognito_user_pool.application.last_modified_date
}

output "client_id" {
  description = "ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.application.id
}

output "client_secret" {
  description = "Secret of the Cognito User Pool Client (sensitive)."
  value       = aws_cognito_user_pool_client.application.client_secret
  sensitive   = true
}

output "client_name" {
  description = "Name of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.application.name
}

output "user_pool_domain" {
  description = "Domain of the Cognito User Pool."
  value       = var.create_user_pool_domain ? aws_cognito_user_pool_domain.application[0].domain : null
}

output "user_pool_domain_aws_account_id" {
  description = "AWS account ID for the user pool domain."
  value       = var.create_user_pool_domain ? aws_cognito_user_pool_domain.application[0].aws_account_id : null
}

output "user_pool_domain_s3_bucket" {
  description = "S3 bucket for the user pool domain."
  value       = var.create_user_pool_domain ? aws_cognito_user_pool_domain.application[0].s3_bucket : null
}
