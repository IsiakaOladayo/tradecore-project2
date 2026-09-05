# =========================================================
# TRADECORE AMPLIFY OUTPUTS
# =========================================================

# ---------------------------------------------------------
# AMPLIFY APP
# ---------------------------------------------------------

output "app_id" {
  description = "ID of the Amplify app."
  value       = aws_amplify_app.application.id
}

output "app_arn" {
  description = "ARN of the Amplify app."
  value       = aws_amplify_app.application.arn
}

output "app_name" {
  description = "Name of the Amplify app."
  value       = aws_amplify_app.application.name
}

output "default_domain" {
  description = "Default domain of the Amplify app."
  value       = aws_amplify_app.application.default_domain
}

output "app_production_branch" {
  description = "Production branch of the Amplify app."
  value       = aws_amplify_app.application.production_branch
}

output "app_repository" {
  description = "Repository URL of the Amplify app."
  value       = aws_amplify_app.application.repository
}

# ---------------------------------------------------------
# AMPLIFY BRANCHES
# ---------------------------------------------------------

output "branch_arns" {
  description = "Map of branch names to their ARNs."
  value       = { for k, v in aws_amplify_branch.application : k => v.arn }
}

output "branch_names" {
  description = "List of branch names created."
  value       = keys(aws_amplify_branch.application)
}

output "branch_details" {
  description = "Map of branch names to their full details."
  value = {
    for k, v in aws_amplify_branch.application : k => {
      arn               = v.arn
      branch_name       = v.branch_name
      display_name      = v.display_name
      stage             = v.stage
      enable_auto_build = v.enable_auto_build
      framework         = v.framework
    }
  }
}

# ---------------------------------------------------------
# DOMAIN ASSOCIATION
# ---------------------------------------------------------

output "domain_association_arn" {
  description = "ARN of the domain association (null if not created)."
  value       = var.create_domain_association ? aws_amplify_domain_association.application[0].arn : null
}

output "domain_association_domain_name" {
  description = "Domain name of the domain association (null if not created)."
  value       = var.create_domain_association ? aws_amplify_domain_association.application[0].domain_name : null
}

# ---------------------------------------------------------
# WEBHOOK
# ---------------------------------------------------------

output "webhook_arn" {
  description = "ARN of the webhook (null if not created)."
  value       = var.create_webhook ? aws_amplify_webhook.application[0].arn : null
}
