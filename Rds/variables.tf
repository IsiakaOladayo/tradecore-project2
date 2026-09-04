# =========================================================
# GENERAL
# =========================================================

variable "project_name" {
  description = "Name of the application/project."
  type        = string
  default     = "tradecore"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["development", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be development, staging, or production."
  }
}

variable "common_tags" {
  description = "Common tags applied to RDS resources."
  type        = map(string)
  default     = {}
}


# =========================================================
# NETWORKING
# =========================================================

variable "vpc_id" {
  description = "VPC ID where RDS is deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS subnet group."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets should be provided."
  }
}

variable "ecs_security_group_id" {
  description = "Security group ID used by ECS tasks. PostgreSQL access is restricted to this security group."
  type        = string
}


# =========================================================
# DATABASE
# =========================================================

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial database storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "tradecore"
}

variable "db_username" {
  description = "Master database username."
  type        = string
}

variable "db_password" {
  description = "Master database password."
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
  default     = 7
}
