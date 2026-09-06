output "db_host_secret_arn" {
  description = "ARN of the DB_HOST secret."
  value       = aws_secretsmanager_secret.db_host.arn
}

output "db_name_secret_arn" {
  description = "ARN of the DB_NAME secret."
  value       = aws_secretsmanager_secret.db_name.arn
}

output "db_user_secret_arn" {
  description = "ARN of the DB_USER secret."
  value       = aws_secretsmanager_secret.db_user.arn
}

output "db_password_secret_arn" {
  description = "ARN of the DB_PASSWORD secret."
  value       = aws_secretsmanager_secret.db_password.arn
}

output "jwt_secret_arn" {
  description = "ARN of the JWT_SECRET secret."
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "secret_arns" {
  description = "Map of all secret ARNs (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, JWT_SECRET)."

  value = {
    DB_HOST     = aws_secretsmanager_secret.db_host.arn
    DB_NAME     = aws_secretsmanager_secret.db_name.arn
    DB_USER     = aws_secretsmanager_secret.db_user.arn
    DB_PASSWORD = aws_secretsmanager_secret.db_password.arn
    JWT_SECRET  = aws_secretsmanager_secret.jwt_secret.arn
  }
}
