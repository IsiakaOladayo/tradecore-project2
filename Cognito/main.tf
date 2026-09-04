# =========================================================
# TRADECORE COGNITO
# =========================================================

# ---------------------------------------------------------
# LOCALS
# ---------------------------------------------------------

locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Auth"
    }
  )
}

# ---------------------------------------------------------
# COGNITO USER POOL
# ---------------------------------------------------------

resource "aws_cognito_user_pool" "application" {
  name = "${var.project_name}-${var.environment}-user-pool"

  # PASSWORD POLICY
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # USERNAME CONFIGURATION
  username_configuration {
    case_sensitive = var.username_case_sensitive
  }

  # AUTO-RECOVER CONFIGURATION
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # EMAIL CONFIGURATION
  email_configuration {
    email_sending_account = var.email_sending_account
  }

  # USER ATTRIBUTE SCHEMA
  dynamic "schema" {
    for_each = var.user_attributes
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      required                 = schema.value.required
      mutable                  = schema.value.mutable
      developer_only_attribute = schema.value.developer_only_attribute

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []
        content {
          min_length = schema.value.min_length
          max_length = schema.value.max_length
        }
      }
    }
  }

  # MFA CONFIGURATION
  mfa_configuration = var.mfa_configuration

  dynamic "sms_configuration" {
    for_each = var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL" ? [1] : []
    content {
      external_id    = var.sms_external_id
      sns_caller_arn = var.sms_caller_arn
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-user-pool"
    }
  )
}

# ---------------------------------------------------------
# COGNITO USER POOL CLIENT
# ---------------------------------------------------------

resource "aws_cognito_user_pool_client" "application" {
  name         = "${var.project_name}-${var.environment}-app-client"
  user_pool_id = aws_cognito_user_pool.application.id

  # AUTH FLOWS
  explicit_auth_flows = var.explicit_auth_flows

  # OAUTH CONFIGURATION
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  supported_identity_providers         = var.supported_identity_providers

  # TOKEN SETTINGS
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # SECURITY SETTINGS
  enable_token_revocation   = var.enable_token_revocation
  prevent_user_existence_errors = var.prevent_user_existence_errors

  # GENERATE SECRET
  generate_secret = var.generate_client_secret
}

# ---------------------------------------------------------
# COGNITO USER POOL DOMAIN (OPTIONAL)
# ---------------------------------------------------------

resource "aws_cognito_user_pool_domain" "application" {
  count = var.create_user_pool_domain ? 1 : 0

  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.application.id
}
