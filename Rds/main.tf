# =========================================================
# TRADECORE RDS
# =========================================================

locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Database"
    }
  )
}

# =========================================================
# RDS SECURITY GROUP
# =========================================================

resource "aws_security_group" "rds" {
  name = "${var.project_name}-${var.environment}-rds-sg"

  description = "RDS PostgreSQL: inbound 5432 from ECS tasks only."

  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )
}

# ECS -> RDS PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "ecs_to_rds" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = var.ecs_security_group_id

  from_port = 5432
  to_port   = 5432

  ip_protocol = "tcp"

  description = "PostgreSQL access from ECS tasks only."
}

# =========================================================
# RDS SUBNET GROUP
# =========================================================

resource "aws_db_subnet_group" "database" {
  name = "${var.project_name}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# =========================================================
# RDS INSTANCE
# =========================================================

resource "aws_db_instance" "database" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.database.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = var.backup_retention_period

  deletion_protection = false

  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  storage_encrypted = true

  apply_immediately = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-postgres"
    }
  )
}
