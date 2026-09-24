locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # HTTPS via LE-imported cert (CERTIFICATE_ARN secret, DOMAIN_NAME unset).
  # LE cert for tradecore-prod.duckdns.org expires 2026-12-23; renew ~2026-11-23.
  # A caller-supplied cert wins; otherwise request one when a domain is set.
  # coalesce() cannot be used here — with no domain it would receive two nulls
  # and fail the plan instead of yielding null.
  certificate_arn = var.certificate_arn != null ? var.certificate_arn : try(module.acm[0].certificate_arn, null)

  # frontend_url may be given bare (d2rv….amplifyapp.com) or fully qualified;
  # building "https://${var.frontend_url}" produced https://https://… .
  frontend_origin = can(regex("^https?://", var.frontend_url)) ? trimsuffix(var.frontend_url, "/") : "https://${var.frontend_url}"
}

module "networking" {
  source = "../Networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags        = local.common_tags
}

module "ecr" {
  source = "../Ecr"

  project_name        = var.project_name
  environment         = var.environment
  ecr_repository_name = var.ecr_repository_name
  common_tags         = local.common_tags
}

module "alb" {
  source = "../Alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  container_port    = var.container_port
  # HTTPS turns on as soon as a cert exists; providing a domain is the only step.
  enable_https    = local.certificate_arn != null
  certificate_arn = local.certificate_arn
  # ALB egress targets the ECS security group. Separate rule resource so the
  # two SGs never reference each other.
  application_security_group_id = module.ecs.ecs_security_group_id
  # Bucket *and* its policy must exist before the ALB references it; the
  # module edge alone only orders the bucket, so depend on the whole module.
  access_log_bucket          = module.logs.bucket_name
  enable_deletion_protection = var.enable_deletion_protection
  common_tags                = local.common_tags

  depends_on = [module.logs]
}

module "ecs" {
  source = "../Ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  container_image             = var.container_image
  container_port              = var.container_port
  cpu                         = var.cpu
  memory                      = var.memory
  desired_count               = var.desired_count
  enable_execute_command      = var.enable_execute_command
  node_env                    = var.node_env
  frontend_url                = var.frontend_url
  db_ssl                      = var.db_ssl
  vpc_cidr                    = var.vpc_cidr
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  alb_security_group_id       = module.alb.alb_security_group_id
  target_group_arn            = module.alb.target_group_arn
  secrets_manager_secret_arns = module.secrets_manager.secret_arns
  service_name                = var.ecs_service_name
  container_name              = var.ecs_container_name
  s3_bucket_name              = module.s3.bucket_name
  common_tags                 = local.common_tags
}

# App stores invoice documents in S3; bucket name injected as S3_BUCKET.
module "s3" {
  source = "../S3"

  environment = var.environment
}

module "rds" {
  source = "../Database"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  monitoring_interval   = var.rds_monitoring_interval
  common_tags           = local.common_tags
}

module "secrets_manager" {
  source = "../SecretsManager"

  project_name = var.project_name
  environment  = var.environment
  db_host      = module.rds.db_endpoint
  db_name      = var.db_name
  db_user      = var.db_username
  db_password  = var.db_password
  jwt_secret   = var.jwt_secret
  common_tags  = local.common_tags
}

module "cognito" {
  source = "../Cognito"

  project_name = var.project_name
  environment  = var.environment

  callback_urls = length(var.cognito_callback_urls) > 0 ? var.cognito_callback_urls : [
    "http://localhost:3000",
    "${local.frontend_origin}/",
    "https://${var.amplify_domain}/"
  ]
  logout_urls = length(var.cognito_logout_urls) > 0 ? var.cognito_logout_urls : [
    "http://localhost:3000",
    "${local.frontend_origin}/",
    "https://${var.amplify_domain}/"
  ]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  create_user_pool_domain = true
  user_pool_domain        = "${var.project_name}-${var.environment}-auth"

  # MFA stays OPTIONAL on TOTP rather than SMS (SMS bills per message and needs
  # an SNS role). generate_client_secret MUST stay false: a browser client is public.
  generate_client_secret  = false
  mfa_configuration       = "OPTIONAL"
  password_minimum_length = 12
  access_token_validity   = 15
  id_token_validity       = 15
  refresh_token_validity  = 7
  # NOT true: username_configuration.case_sensitive is ForceNew, so flipping it
  # would destroy and recreate the user pool — changing both the pool ID and the
  # client ID that the frontend hardcodes in aws-exports.js.
  username_case_sensitive = false

  common_tags = local.common_tags
}

# Amplify frontend is console-managed (app dpqtxdawh7h1c); Terraform tracks only
# its ID/domain via vars so Cognito callbacks and outputs stay correct.
# (module "amplify" removed 2026-09-24: it kept recreating an empty app.)

# Created only when domain_name is set.
module "acm" {
  source = "../Acm"
  count  = var.domain_name != null ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name
  common_tags  = local.common_tags
}

module "iam" {
  source = "./iam"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_org_id      = var.github_org_id
  github_repo_id     = var.github_repo_id
  app_github_org     = var.app_github_org
  app_github_repo    = var.app_github_repo
  app_github_org_id  = var.app_github_org_id
  app_github_repo_id = var.app_github_repo_id
}

module "state" {
  source = "./state"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "logs" {
  source = "./logs"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "observability" {
  source = "../Observability"

  project_name        = var.project_name
  environment         = var.environment
  alb_id              = module.alb.alb_id
  target_group_id     = module.alb.target_group_id
  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name
  ecs_desired_count   = coalesce(var.desired_count, 2)
  db_instance_id      = module.rds.db_instance_id
  budget_limit_usd    = var.budget_limit_usd
  budget_alert_emails = var.budget_alert_emails
  log_bucket_name     = module.logs.bucket_name
  common_tags         = local.common_tags

  # Trail validates the bucket policy at creation; wait for the whole module.
  depends_on = [module.logs]
}
