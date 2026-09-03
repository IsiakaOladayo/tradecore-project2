output "db_host_secret_arn" {
  description = "ARN of the DB_HOST secret"
  value       = aws_secretsmanager_secret.db_host.arn
}

output "db_name_secret_arn" {
  description = "ARN of the DB_NAME secret"
  value       = aws_secretsmanager_secret.db_name.arn
}

output "db_user_secret_arn" {
  description = "ARN of the DB_USER secret"
  value       = aws_secretsmanager_secret.db_user.arn
}

output "db_password_secret_arn" {
  description = "ARN of the DB_PASSWORD secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "jwt_secret_arn" {
  description = "ARN of the JWT_SECRET secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "secret_arns" {
  description = "ARNs of all TradeCore application secrets"

  value = {
    db_host     = aws_secretsmanager_secret.db_host.arn
    db_name     = aws_secretsmanager_secret.db_name.arn
    db_user     = aws_secretsmanager_secret.db_user.arn
    db_password = aws_secretsmanager_secret.db_password.arn
    jwt_secret  = aws_secretsmanager_secret.jwt_secret.arn
  }
}

