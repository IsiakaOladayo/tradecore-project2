variable "project_name" {
  description = "Name of the application/project."
  type        = string
  default     = "tradecore"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "common_tags" {
  description = "Common tags applied to Database resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the TradeCore VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where RDS will be deployed."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS service allowed to access RDS PostgreSQL."
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "tradecore"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL master password."
  type        = string
  sensitive   = true
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot when the RDS instance is destroyed."
  type        = string
  default     = null
}
