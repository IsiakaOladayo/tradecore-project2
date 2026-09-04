# =========================================================
# TRADECORE - ROOT MODULE
# =========================================================

# ---------------------------------------------------------
# MODULE: NETWORKING
# ---------------------------------------------------------

module "networking" {
  source = "../Networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# ---------------------------------------------------------
# MODULE: ALB
# ---------------------------------------------------------

module "alb" {
  source = "../Alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  container_port             = var.container_port
  enable_https               = true
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
}

# ---------------------------------------------------------
# MODULE: ECS
# ---------------------------------------------------------

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
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  alb_security_group_id       = module.alb.alb_security_group_id
  target_group_arn            = module.alb.target_group_arn
  secrets_manager_secret_arns = module.secrets_manager.secret_arns
}

# ---------------------------------------------------------
# MODULE: RDS (DATABASE)
# ---------------------------------------------------------

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
}

# ---------------------------------------------------------
# MODULE: SECRETS MANAGER
# ---------------------------------------------------------

module "secrets_manager" {
  source = "../SecretsManager"

  project_name = var.project_name
  environment  = var.environment
  db_host      = module.rds.db_endpoint
  db_name      = var.db_name
  db_user      = var.db_username
  db_password  = var.db_password
  jwt_secret   = var.jwt_secret
}

# ---------------------------------------------------------
# MODULE: COGNITO
# ---------------------------------------------------------

module "cognito" {
  source = "../Cognito"

  project_name  = var.project_name
  environment   = var.environment
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls
}

# ---------------------------------------------------------
# MODULE: AMPLIFY
# ---------------------------------------------------------

module "amplify" {
  source = "../Amplify"

  project_name = var.project_name
  environment  = var.environment
  repository   = var.amplify_repository
  access_token = var.amplify_access_token
}

# ---------------------------------------------------------
# MODULE: IAM (OIDC + GITHUB ACTIONS)
# ---------------------------------------------------------

module "iam" {
  source = "./iam"

  project_name   = var.project_name
  environment    = var.environment
  github_org     = "IsiakaOladayo"
  github_repo    = "tradecore-project2"
  allowed_branch = "main"
}
