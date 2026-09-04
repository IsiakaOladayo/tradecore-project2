
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
  description = "Common tags applied to ALB resources."
  type        = map(string)
  default     = {}
}


# =========================================================
# NETWORKING
# =========================================================

variable "vpc_id" {
  description = "VPC ID where the ALB and its target group are deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs the ALB is deployed into."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least two public subnets should be provided."
  }
}

variable "internal" {
  description = "Whether the ALB is internal (private) or internet-facing."
  type        = bool
  default     = false
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB listeners."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


# =========================================================
# TARGET GROUP / HEALTH CHECK
# =========================================================

variable "container_port" {
  description = "Port the ECS application container listens on. Used as the target group port."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check."
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Approximate time, in seconds, between target group health checks."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Time, in seconds, to wait for a target group health check response."
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks before a target is healthy."
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks before a target is unhealthy."
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP status codes considered a successful health check response."
  type        = string
  default     = "200"
}

variable "deregistration_delay" {
  description = "Seconds the ALB waits before deregistering a draining target."
  type        = number
  default     = 30
}


# =========================================================
# LISTENERS / TLS
# =========================================================

variable "enable_https" {
  description = "Whether to create an HTTPS listener. Requires certificate_arn to also be set."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN used by the HTTPS listener. Required when enable_https is true."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy applied to the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}


# =========================================================
# LOAD BALANCER
# =========================================================

variable "idle_timeout" {
  description = "Time, in seconds, the ALB keeps an idle connection open."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the ALB."
  type        = bool
  default     = false
}
