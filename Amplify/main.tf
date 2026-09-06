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

resource "aws_amplify_app" "application" {
  name       = "${var.project_name}-${var.environment}-app"
  repository = var.repository

  access_token = var.access_token
  build_spec   = var.build_spec

  environment_variables = var.environment_variables
  oauth_token           = var.oauth_token

  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion
  custom_headers              = var.custom_headers
  platform                    = var.platform

  enable_auto_branch_creation  = var.enable_auto_branch_creation
  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  dynamic "auto_branch_creation_config" {
    for_each = var.enable_auto_branch_creation ? [1] : []
    content {
      basic_auth_credentials        = var.auto_branch_creation_basic_auth_credentials
      build_spec                    = var.auto_branch_creation_build_spec
      enable_auto_build             = var.auto_branch_creation_enable_auto_build
      enable_performance_mode       = var.auto_branch_creation_enable_performance_mode
      enable_pull_request_preview   = var.auto_branch_creation_enable_pull_request_preview
      environment_variables         = var.auto_branch_creation_environment_variables
      framework                     = var.auto_branch_creation_framework
      stage                         = var.auto_branch_creation_stage
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-amplify-app"
    }
  )
}

resource "aws_amplify_branch" "application" {
  for_each = { for branch in var.branches : branch.name => branch }

  app_id      = aws_amplify_app.application.id
  branch_name = each.value.name

  description               = lookup(each.value, "description", null)
  display_name              = lookup(each.value, "display_name", null)
  enable_auto_build         = lookup(each.value, "enable_auto_build", var.enable_branch_auto_build)
  enable_performance_mode   = lookup(each.value, "enable_performance_mode", false)
  enable_pull_request_preview = lookup(each.value, "enable_pull_request_preview", false)
  environment_variables     = lookup(each.value, "environment_variables", {})
  framework                 = lookup(each.value, "framework", null)
  stage                     = lookup(each.value, "stage", "PRODUCTION")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${each.value.name}"
    }
  )
}

resource "aws_amplify_domain_association" "application" {
  count = var.create_domain_association ? 1 : 0

  app_id      = aws_amplify_app.application.id
  domain_name = var.domain_name

  dynamic "sub_domain" {
    for_each = var.sub_domain_settings
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }

  certificate_settings {
    type                   = var.certificate_type
    custom_certificate_arn = var.certificate_custom_certificate_arn
  }
}

resource "aws_amplify_webhook" "application" {
  count = var.create_webhook ? 1 : 0

  app_id      = aws_amplify_app.application.id
  branch_name = var.webhook_branch_name
  description = var.webhook_description
}
