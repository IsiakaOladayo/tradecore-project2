# Environment

variable "environment" {
  description = "TradeCore deployment environment"
  type        = string
  default     = "production"
}


# Networking

variable "private_subnet_ids" {
  description = "Private subnet IDs where RDS will be deployed"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Security group ID attached to RDS"
  type        = string
}


# Database

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "tradecore"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}
