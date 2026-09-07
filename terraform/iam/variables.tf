variable "project_name" {
  description = "Name of the application/project."
  type        = string
  default     = "tradecore"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed."
  type        = string
}

variable "github_org" {
  description = "GitHub organization name."
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
