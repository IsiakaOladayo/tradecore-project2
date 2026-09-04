# ENVIRONMENT

variable "environment" {
  description = "TradeCore deployment environment"
  type        = string
  default     = "production"
}


# NETWORKING

variable "vpc_id" {
  description = "ID of the TradeCore VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where RDS will be deployed"
  type        = list(string)
}


# ECS SECURITY

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS service allowed to access RDS PostgreSQL"
  type        = string
}


# DATABASE

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
