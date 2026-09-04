# =========================================================
# TRADECORE SECRETS MANAGER
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
      Layer       = "Secrets"
    }
  )
}

# ---------------------------------------------------------
# DB_HOST
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "db_host" {
  name = "/${var.project_name}/${var.environment}/db-host"

  tags = merge(
    local.common_tags,
    {
      Name = "/${var.project_name}/${var.environment}/db-host"
    }
  )
}

# ---------------------------------------------------------
# DB_NAME
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "db_name" {
  name = "/${var.project_name}/${var.environment}/db-name"

  tags = merge(
    local.common_tags,
    {
      Name = "/${var.project_name}/${var.environment}/db-name"
    }
  )
}

# ---------------------------------------------------------
# DB_USER
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "db_user" {
  name = "/${var.project_name}/${var.environment}/db-user"

  tags = merge(
    local.common_tags,
    {
      Name = "/${var.project_name}/${var.environment}/db-user"
    }
  )
}

# ---------------------------------------------------------
# DB_PASSWORD
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "db_password" {
  name = "/${var.project_name}/${var.environment}/db-password"

  tags = merge(
    local.common_tags,
    {
      Name = "/${var.project_name}/${var.environment}/db-password"
    }
  )
}

# ---------------------------------------------------------
# JWT_SECRET
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "/${var.project_name}/${var.environment}/jwt-secret"

  tags = merge(
    local.common_tags,
    {
      Name = "/${var.project_name}/${var.environment}/jwt-secret"
    }
  )
}

# =========================================================
# SECRET VERSIONS
# =========================================================

resource "aws_secretsmanager_secret_version" "db_host" {
  secret_id = aws_secretsmanager_secret.db_host.id

  secret_string = var.db_host
}

resource "aws_secretsmanager_secret_version" "db_name" {
  secret_id = aws_secretsmanager_secret.db_name.id

  secret_string = var.db_name
}

resource "aws_secretsmanager_secret_version" "db_user" {
  secret_id = aws_secretsmanager_secret.db_user.id

  secret_string = var.db_user
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id

  secret_string = var.db_password
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id

  secret_string = var.jwt_secret
}
