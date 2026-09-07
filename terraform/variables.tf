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

variable "aws_region" {
  description = "AWS region where all resources are deployed."
  type        = string
  default     = "af-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name for authentication."
  type        = string
  default     = "ENOFE"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones."
  type        = list(string)
  default     = ["af-south-1a", "af-south-1b"]
}

variable "domain_name" {
  description = "Domain name for ACM certificate (optional - enable later with duckdns.org)."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Docker image URI for the ECS application container."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 4000
}

variable "cpu" {
  description = "CPU units allocated to the ECS task."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB allocated to the ECS task."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = null
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for interactive troubleshooting."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
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

variable "jwt_secret" {
  description = "JWT signing secret."
  type        = string
  sensitive   = true
}

variable "cognito_callback_urls" {
  description = "Callback URLs for Cognito OAuth."
  type        = list(string)
  default     = []
}

variable "cognito_logout_urls" {
  description = "Logout URLs for Cognito OAuth."
  type        = list(string)
  default     = []
}

variable "amplify_repository" {
  description = "GitHub repository URL for Amplify."
  type        = string
  default     = null
}

variable "amplify_access_token" {
  description = "GitHub PAT for Amplify."
  type        = string
  sensitive   = true
  default     = null
}

variable "github_org" {
  description = "GitHub organization or username."
  type        = string
  default     = "IsiakaOladayo"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "tradecore-project2"
}

variable "github_org_id" {
  description = "Numeric GitHub organization ID."
  type        = string
}

variable "github_repo_id" {
  description = "Numeric GitHub repository ID."
  type        = string
}
