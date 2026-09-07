locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
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

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "alb" {
  source = "../Alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  container_port             = var.container_port
  enable_https               = false
  certificate_arn            = null
  enable_deletion_protection = var.enable_deletion_protection
  common_tags                = local.common_tags
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
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  alb_security_group_id       = module.alb.alb_security_group_id
  target_group_arn            = module.alb.target_group_arn
  secrets_manager_secret_arns = module.secrets_manager.secret_arns
  common_tags                 = local.common_tags
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

  project_name  = var.project_name
  environment   = var.environment
  callback_urls = ["http://localhost:3000"]
  logout_urls   = ["http://localhost:3000"]

  allowed_oauth_flows                  = []
  allowed_oauth_scopes                 = []
  allowed_oauth_flows_user_pool_client = false

  common_tags = local.common_tags
}

module "amplify" {
  source = "../Amplify"

  providers = {
    aws = aws.us_east_1
  }

  project_name = var.project_name
  environment  = var.environment
  repository   = var.amplify_repository
  access_token = var.amplify_access_token
}

module "iam" {
  source = "./iam"

  project_name   = var.project_name
  environment    = var.environment
  aws_region     = var.aws_region
  github_org     = var.github_org
  github_repo    = var.github_repo
}

module "state" {
  source = "./state"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}
