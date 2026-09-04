#Tradecore networking variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "Tradecore VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["af-south-1a", "af-south-1b"]
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS service allowed to access RDS PostgreSQL"
  type        = string
}
