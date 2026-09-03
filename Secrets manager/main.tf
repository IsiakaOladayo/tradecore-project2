# TradeCore Secrets Manager

# DB_HOST

resource "aws_secretsmanager_secret" "db_host" {
  name       = "/tradecore/${var.environment}/db-host"

  tags = {
    Name        = "tradecore-${var.environment}-db-host"
    Environment = var.environment
  }
}

# DB_NAME

resource "aws_secretsmanager_secret" "db_name" {
  name       = "/tradecore/${var.environment}/db-name"

  tags = {
    Name        = "tradecore-${var.environment}-db-name"
    Environment = var.environment
  }
}

# DB_USER

resource "aws_secretsmanager_secret" "db_user" {
  name       = "/tradecore/${var.environment}/db-user"

  tags = {
    Name        = "tradecore-${var.environment}-db-user"
    Environment = var.environment
  }
}

# DB_PASSWORD

resource "aws_secretsmanager_secret" "db_password" {
  name       = "/tradecore/${var.environment}/db-password"

  tags = {
    Name        = "tradecore-${var.environment}-db-password"
    Environment = var.environment
  }
}

# JWT_SECRET

resource "aws_secretsmanager_secret" "jwt_secret" {
  name       = "/tradecore/${var.environment}/jwt-secret"

  tags = {
    Name        = "tradecore-${var.environment}-jwt-secret"
    Environment = var.environment
  }
}
