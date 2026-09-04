output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.tradecore.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.tradecore.arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.tradecore.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.tradecore.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.tradecore.db_name
}

output "database_security_group_id" {
  description = "Security group ID for the TradeCore RDS database"
  value       = aws_security_group.database.id
}
