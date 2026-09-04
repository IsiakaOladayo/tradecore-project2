# =========================================================
# TRADECORE - IAM VARIABLES
# =========================================================

variable "project_name" {
  description = "Name of the application/project."
  type        = string
  default     = "tradecore"
}

variable "environment" {
  description = "Deployment environment."
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

variable "allowed_branch" {
  description = "Branch allowed to assume the GitHub Actions role."
  type        = string
  default     = "main"
}
