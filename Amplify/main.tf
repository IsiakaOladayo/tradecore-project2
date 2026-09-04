# =========================================================
# TRADECORE AMPLIFY
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
      Layer       = "Frontend"
    }
  )
}

# ---------------------------------------------------------
# AMPLIFY APP
# ---------------------------------------------------------

resource "aws_amplify_app" "application" {
  name       = "${var.project_name}-${var.environment}-app"
  repository = var.repository

  # ACCESS TOKEN
  access_token = var.access_token

  # BUILD SPEC
  build_spec = var.build_spec

  # ENVIRONMENT VARIABLES
  environment_variables = var.environment_variables

  # OAUTH TOKEN
  oauth_token = var.oauth_token

  # ENABLE BRANCH AUTO BUILD
  enable_branch_auto_build = var.enable_branch_auto_build

  # ENABLE BRANCH AUTO DELETION
  enable_branch_auto_deletion = var.enable_branch_auto_deletion

  # CUSTOM RULES
  dynamic "custom_rules" {
    for_each = var.custom_rules
    content {
      source    = custom_rules.value.source
      target    = custom_rules.value.target
      status    = custom_rules.value.status
      condition = custom_rules.value.condition
    }
  }

  # CUSTOM HEADERS
  custom_headers = var.custom_headers

  # PLUGINS
  dynamic "plugins" {
    for_each = var.plugins
    content {
      name    = plugins.value.name
      version = plugins.value.version
    }
  }

  # PLATFORM
  platform = var.platform

  # ENABLE AUTO BRANCH CREATION
  enable_auto_branch_creation = var.enable_auto_branch_creation

  # AUTO BRANCH CREATION PATTERNS
  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  # AUTO BRANCH CREATION CONFIG
  dynamic "auto_branch_creation_config" {
    for_each = var.enable_auto_branch_creation ? [1] : []
    content {
      basic_auth_credentials = var.auto_branch_creation_basic_auth_credentials
      build_spec             = var.auto_branch_creation_build_spec
      description            = var.auto_branch_creation_description
      enable_auto_build      = var.auto_branch_creation_enable_auto_build
      enable_performance_mode = var.auto_branch_creation_enable_performance_mode
      enable_pull_request_preview = var.auto_branch_creation_enable_pull_request_preview
      environment_variables  = var.auto_branch_creation_environment_variables
      framework              = var.auto_branch_creation_framework
      stage                  = var.auto_branch_creation_stage
      trigger_rule           = var.auto_branch_creation_trigger_rule
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-amplify-app"
    }
  )
}

# ---------------------------------------------------------
# AMPLIFY BRANCHES
# ---------------------------------------------------------

resource "aws_amplify_branch" "application" {
  for_each = { for branch in var.branches : branch.name => branch }

  app_id      = aws_amplify_app.application.id
  branch_name = each.value.name

  # DESCRIPTION
  description = lookup(each.value, "description", null)

  # DISPLAY NAME
  display_name = lookup(each.value, "display_name", null)

  # ENABLE AUTO BUILD
  enable_auto_build = lookup(each.value, "enable_auto_build", var.enable_branch_auto_build)

  # ENABLE PERFORMANCE MODE
  enable_performance_mode = lookup(each.value, "enable_performance_mode", false)

  # ENABLE PULL REQUEST PREVIEW
  enable_pull_request_preview = lookup(each.value, "enable_pull_request_preview", true)

  # ENVIRONMENT VARIABLES
  environment_variables = lookup(each.value, "environment_variables", {})

  # FRAMEWORK
  framework = lookup(each.value, "framework", null)

  # STAGE
  stage = lookup(each.value, "stage", "PRODUCTION")

  # TOTAL BANDWIDTH
  total_bandwidth = lookup(each.value, "total_bandwidth", null)

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${each.value.name}"
    }
  )
}

# ---------------------------------------------------------
# AMPLIFY DOMAIN ASSOCIATION (OPTIONAL)
# ---------------------------------------------------------

resource "aws_amplify_domain_association" "application" {
  count = var.create_domain_association ? 1 : 0

  app_id      = aws_amplify_app.application.id
  domain_name = var.domain_name

  # SUB DOMAIN SETTINGS
  dynamic "sub_domain_settings" {
    for_each = var.sub_domain_settings
    content {
      branch_name = sub_domain_settings.value.branch_name
      prefix      = sub_domain_settings.value.prefix
    }
  }

  # CERTIFICATE SETTINGS (OPTIONAL)
  certificate_settings {
    type                   = var.certificate_type
    custom_certificate_arn = var.certificate_custom_certificate_arn
  }
}

# ---------------------------------------------------------
# AMPLIFY WEBHOOKS (OPTIONAL)
# ---------------------------------------------------------

resource "aws_amplify_webhook" "application" {
  count = var.create_webhook ? 1 : 0

  app_id      = aws_amplify_app.application.id
  branch_name = var.webhook_branch_name
  description = var.webhook_description
}
