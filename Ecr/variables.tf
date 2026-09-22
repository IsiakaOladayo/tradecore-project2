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
    error_message = "Environment must be development, staging, or production."
  }
}

variable "common_tags" {
  description = "Common tags applied to ECR resources."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_name" {
  description = "ECR repository name. Must match the name the application CI pushes to."
  type        = string
  default     = "tradecore-api"
}
