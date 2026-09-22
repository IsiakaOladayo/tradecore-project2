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

variable "aws_region" {
  description = "AWS region where ECS resources are deployed."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to ECS resources."
  type        = map(string)
  default     = {}
}

variable "container_image" {
  description = "Docker image URI used by the ECS application container."
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

variable "vpc_id" {
  description = "VPC ID where ECS resources are deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to scope DNS egress to the VPC resolver."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by ECS Fargate tasks."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least two public subnets should be provided."
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

variable "target_group_arn" {
  description = "ARN of the ALB target group used by the ECS service."
  type        = string
}

variable "service_name" {
  description = "ECS service name. Must match the name the application CI calls in update-service."
  type        = string
  default     = "tradecore-api-production"
}

variable "container_name" {
  description = "Container name. Must match the name the application CI passes to amazon-ecs-render-task-definition."
  type        = string
  default     = "tradecore-api"
}

variable "secrets_manager_secret_arns" {
  description = "Map of container environment variable names to Secrets Manager ARNs."
  type        = map(string)
  default     = {}
}

variable "secrets_kms_key_arn" {
  description = "KMS key ARN used to encrypt Secrets Manager secrets. Null when using the default Secrets Manager key."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days CloudWatch application logs are retained."
  type        = number
  default     = 30
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for interactive troubleshooting."
  type        = bool
  default     = false
}

variable "node_env" {
  description = "NODE_ENV for the application. Production masks stack traces in 500 responses."
  type        = string
  default     = "production"
}

variable "frontend_url" {
  description = "Allowed CORS origin for the frontend. Used by the app to permit Amplify requests."
  type        = string
  default     = "https://d2rvcx1xtsfbat.amplifyapp.com"
}

variable "db_ssl" {
  description = "Whether the app should use TLS for its Postgres connection."
  type        = string
  default     = "true"
}

variable "s3_bucket_name" {
  description = "Application data bucket injected as S3_BUCKET for invoice uploads."
  type        = string
  default     = ""
}
