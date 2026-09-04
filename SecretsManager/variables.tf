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
  description = "Common tags applied to Secrets Manager resources."
  type        = map(string)
  default     = {}
}

# =========================================================
# SECRET VALUES
# =========================================================

variable "db_host" {
  description = "Database host endpoint."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name."
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Database master username."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret."
  type        = string
  sensitive   = true
}

