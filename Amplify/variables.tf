# =========================================================
# TRADECORE AMPLIFY VARIABLES
# =========================================================

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
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "common_tags" {
  description = "Common tags applied to Amplify resources."
  type        = map(string)
  default     = {}
}

# =========================================================
# REPOSITORY CONFIGURATION
# =========================================================

variable "repository" {
  description = "GitHub repository URL for the Amplify app."
  type        = string
}

variable "access_token" {
  description = "GitHub personal access token for Amplify (sensitive)."
  type        = string
  sensitive   = true
  default     = null
}

variable "oauth_token" {
  description = "OAuth token for GitHub repository access (sensitive)."
  type        = string
  sensitive   = true
  default     = null
}

# =========================================================
# BUILD CONFIGURATION
# =========================================================

variable "build_spec" {
  description = "Build specification for the Amplify app (YAML string)."
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Map of environment variables for the Amplify app."
  type        = map(string)
  default     = {}
}

variable "platform" {
  description = "Platform for the Amplify app (WEB, WEB_COMPUTE)."
  type        = string
  default     = "WEB"

  validation {
    condition     = contains(["WEB", "WEB_COMPUTE"], var.platform)
    error_message = "Platform must be either WEB or WEB_COMPUTE."
  }
}

# =========================================================
# BRANCH CONFIGURATION
# =========================================================

variable "branches" {
  description = "List of branches to create for the Amplify app."
  type = list(object({
    name                      = string
    description               = optional(string)
    display_name              = optional(string)
    enable_auto_build         = optional(bool)
    enable_performance_mode   = optional(bool)
    enable_pull_request_preview = optional(bool)
    environment_variables     = optional(map(string))
    framework                 = optional(string)
    stage                     = optional(string)
    total_bandwidth           = optional(number)
  }))
  default = [
    {
      name  = "main"
      stage = "PRODUCTION"
    }
  ]
}

variable "enable_branch_auto_build" {
  description = "Default auto-build setting for branches."
  type        = bool
  default     = true
}

# =========================================================
# CUSTOM RULES
# =========================================================

variable "custom_rules" {
  description = "List of custom rewrite/redirect rules for the Amplify app."
  type = list(object({
    source    = string
    target    = string
    status    = optional(string)
    condition = optional(string)
  }))
  default = [
    {
      source = "/<*>"
      target = "/index.html"
      status = "404-rewrite"
    }
  ]
}

variable "custom_headers" {
  description = "Custom headers for the Amplify app."
  type        = string
  default     = null
}

# =========================================================
# PLUGINS
# =========================================================

variable "plugins" {
  description = "List of Amplify plugins to enable."
  type = list(object({
    name    = string
    version = string
  }))
  default = []
}

# =========================================================
# AUTO BRANCH CREATION
# =========================================================

variable "enable_auto_branch_creation" {
  description = "Whether to enable auto branch creation for the Amplify app."
  type        = bool
  default     = false
}

variable "auto_branch_creation_patterns" {
  description = "Patterns for auto branch creation."
  type        = list(string)
  default     = []
}

variable "auto_branch_creation_basic_auth_credentials" {
  description = "Basic auth credentials for auto branch creation."
  type        = string
  default     = null
}

variable "auto_branch_creation_build_spec" {
  description = "Build spec for auto branch creation."
  type        = string
  default     = null
}

variable "auto_branch_creation_description" {
  description = "Description for auto branch creation."
  type        = string
  default     = null
}

variable "auto_branch_creation_enable_auto_build" {
  description = "Whether auto branches are automatically built."
  type        = bool
  default     = true
}

variable "auto_branch_creation_enable_performance_mode" {
  description = "Whether to enable performance mode for auto branches."
  type        = bool
  default     = false
}

variable "auto_branch_creation_enable_pull_request_preview" {
  description = "Whether to enable pull request preview for auto branches."
  type        = bool
  default     = true
}

variable "auto_branch_creation_environment_variables" {
  description = "Environment variables for auto branch creation."
  type        = map(string)
  default     = {}
}

variable "auto_branch_creation_framework" {
  description = "Framework for auto branch creation (e.g., REACT, NEXT, VUE)."
  type        = string
  default     = null
}

variable "auto_branch_creation_stage" {
  description = "Stage for auto branch creation (PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL)."
  type        = string
  default     = "DEVELOPMENT"
}

variable "auto_branch_creation_trigger_rule" {
  description = "Trigger rule for auto branch creation."
  type        = string
  default     = null
}

# =========================================================
# DOMAIN ASSOCIATION (OPTIONAL)
# =========================================================

variable "create_domain_association" {
  description = "Whether to create a domain association for the Amplify app."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for the Amplify app."
  type        = string
  default     = null
}

variable "sub_domain_settings" {
  description = "Sub-domain settings for the domain association."
  type = list(object({
    branch_name = string
    prefix      = string
  }))
  default = [
    {
      branch_name = "main"
      prefix      = ""
    }
  ]
}

variable "certificate_type" {
  description = "Certificate type for the domain association (AMPLIFY_MANAGED, CUSTOM)."
  type        = string
  default     = "AMPLIFY_MANAGED"
}

variable "certificate_custom_certificate_arn" {
  description = "Custom certificate ARN for the domain association."
  type        = string
  default     = null
}

# =========================================================
# WEBHOOK (OPTIONAL)
# =========================================================

variable "create_webhook" {
  description = "Whether to create a webhook for the Amplify app."
  type        = bool
  default     = false
}

variable "webhook_branch_name" {
  description = "Branch name for the webhook."
  type        = string
  default     = "main"
}

variable "webhook_description" {
  description = "Description for the webhook."
  type        = string
  default     = null
}
