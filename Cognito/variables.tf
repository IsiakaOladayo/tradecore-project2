# =========================================================
# TRADECORE COGNITO VARIABLES
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
  description = "Common tags applied to Cognito resources."
  type        = map(string)
  default     = {}
}

# =========================================================
# USER POOL PASSWORD POLICY
# =========================================================

variable "password_minimum_length" {
  description = "Minimum length of the password for the user pool."
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Whether the password require a lowercase letter."
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether the password require a number."
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether the password require a symbol."
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether the password require an uppercase letter."
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid."
  type        = number
  default     = 7
}

# =========================================================
# USERNAME CONFIGURATION
# =========================================================

variable "username_case_sensitive" {
  description = "Whether the username field is case sensitive."
  type        = bool
  default     = false
}

# =========================================================
# EMAIL CONFIGURATION
# =========================================================

variable "email_sending_account" {
  description = "Email sending account type (COGNITO_DEFAULT, DEVELOPER)."
  type        = string
  default     = "COGNITO_DEFAULT"
}

# =========================================================
# USER ATTRIBUTE SCHEMA
# =========================================================

variable "user_attributes" {
  description = "List of user attribute schema definitions."
  type = list(object({
    name                     = string
    attribute_data_type      = string
    required                 = bool
    mutable                  = bool
    developer_only_attribute = bool
    min_length               = optional(number)
    max_length               = optional(number)
  }))
  default = [
    {
      name                     = "email"
      attribute_data_type      = "String"
      required                 = true
      mutable                  = true
      developer_only_attribute = false
      min_length               = 5
      max_length               = 256
    },
    {
      name                     = "name"
      attribute_data_type      = "String"
      required                 = true
      mutable                  = true
      developer_only_attribute = false
      min_length               = 1
      max_length               = 256
    }
  ]
}

# =========================================================
# MFA CONFIGURATION
# =========================================================

variable "mfa_configuration" {
  description = "MFA configuration for the user pool (OFF, ON, OPTIONAL)."
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "sms_external_id" {
  description = "External ID for SMS configuration."
  type        = string
  default     = null
}

variable "sms_caller_arn" {
  description = "ARN of the IAM role for SMS configuration."
  type        = string
  default     = null
}

# =========================================================
# TOKEN REVOCATION & USER EXISTENCE
# =========================================================

variable "enable_token_revocation" {
  description = "Whether to enable token revocation for the user pool client."
  type        = bool
  default     = true
}

variable "prevent_user_existence_errors" {
  description = "Whether to prevent user existence errors (ENABLED or LEGACY)."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "LEGACY"], var.prevent_user_existence_errors)
    error_message = "Prevent user existence errors must be ENABLED or LEGACY."
  }
}

# =========================================================
# USER POOL CLIENT - AUTH FLOWS
# =========================================================

variable "explicit_auth_flows" {
  description = "List of explicit authentication flows for the user pool client."
  type        = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# =========================================================
# USER POOL CLIENT - OAUTH CONFIGURATION
# =========================================================

variable "callback_urls" {
  description = "List of allowed callback URLs for OAuth."
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs for OAuth."
  type        = list(string)
  default     = []
}

variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows (code, implicit, client_credentials)."
  type        = list(string)
  default     = ["code"]
}

variable "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes."
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

variable "allowed_oauth_flows_user_pool_client" {
  description = "Whether the user pool client is allowed for OAuth flows."
  type        = bool
  default     = true
}

variable "supported_identity_providers" {
  description = "List of supported identity providers for the user pool client."
  type        = list(string)
  default     = ["COGNITO"]
}

# =========================================================
# USER POOL CLIENT - TOKEN VALIDITY
# =========================================================

variable "access_token_validity" {
  description = "Validity period of the access token in minutes."
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Validity period of the ID token in minutes."
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Validity period of the refresh token in days."
  type        = number
  default     = 30
}

# =========================================================
# USER POOL CLIENT - SECURITY
# =========================================================

variable "generate_client_secret" {
  description = "Whether to generate a client secret for the user pool client."
  type        = bool
  default     = false
}

# =========================================================
# USER POOL DOMAIN (OPTIONAL)
# =========================================================

variable "create_user_pool_domain" {
  description = "Whether to create a custom domain for the user pool."
  type        = bool
  default     = false
}

variable "user_pool_domain" {
  description = "Custom domain name for the user pool."
  type        = string
  default     = null
}
