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

variable "aws_region" {
  description = "AWS region where ECS resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to ECS resources."
  type        = map(string)
  default     = {}
}


# =========================================================
# ECS COMPUTE
# =========================================================

variable "container_image" {
  description = "Docker image URI used by the ECS application container."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units allocated to the ECS task."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory in MiB allocated to the ECS task."
  type        = number
  default     = 1024
}

variable "app_version" {
  description = "Application version."
  type        = string
  default     = "1.0.0"
}

variable "health_check_path" {
  description = "HTTP path used for the container health check."
  type        = string
  default     = "/health"
}

variable "desired_count" {
  description = "Desired number of ECS tasks. Null enables environment-based defaults."
  type        = number
  default     = null
}


# =========================================================
# NETWORKING
# =========================================================

variable "vpc_id" {
  description = "VPC ID where ECS resources are deployed."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs used by ECS Fargate tasks."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_ids) >= 2
    error_message = "At least two private application subnets should be provided."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer."
  type        = string
}

variable "application_security_group_id" {
  description = "Existing ECS application security group ID. If null, Terraform creates one."
  type        = string
  default     = null
}

variable "rds_security_group_id" {
  description = "Security group ID attached to the RDS database."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group used by the ECS service."
  type        = string
}


# =========================================================
# SECRETS MANAGER
# =========================================================

variable "secrets_manager_secret_arns" {
  description = "Map of container environment variable names to Secrets Manager ARNs."

  type = map(string)

  default = {}

  # Example:
  #
  # {
  #   DB_HOST     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:/tradecore/production/db-host"
  #   DB_NAME     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:/tradecore/production/db-name"
  #   DB_USER     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:/tradecore/production/db-user"
  #   DB_PASSWORD = "arn:aws:secretsmanager:us-east-1:123456789012:secret:/tradecore/production/db-password"
  # }
}

variable "secrets_kms_key_arn" {
  description = "KMS key ARN used to encrypt Secrets Manager secrets. Null when using the default Secrets Manager key."
  type        = string
  default     = null
}


# =========================================================
# CLOUDWATCH
# =========================================================

variable "log_retention_days" {
  description = "Number of days CloudWatch application logs are retained."
  type        = number
  default     = 30
}


# =========================================================
# ECS EXEC
# =========================================================

variable "enable_execute_command" {
  description = "Enable ECS Exec for interactive troubleshooting."
  type        = bool
  default     = false
}
