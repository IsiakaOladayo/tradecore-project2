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

resource "aws_db_subnet_group" "tradecore" {
  name = "${var.project_name}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Security group for TradeCore RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL access from ECS only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  # 027 — RDS initiates no outbound connections; responses to the allowed
  # 5432 ingress are covered by security-group statefulness.
  #
  # Intentionally NO egress block here. An egress rule with an empty CIDR set
  # (protocol "-1", cidr_blocks = []) is not storable — AWS keeps no such rule,
  # so declaring one leaves the plan permanently dirty, re-adding it each run.
  # Omitting the block instead leaves egress at zero rules, which is the intent.

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-database-sg"
      Tier = "Database"
    }
  )
}

# 027 — declared here rather than inline in the ECS SG to avoid a module cycle
# (this SG already references the ECS SG for its ingress rule).
resource "aws_security_group_rule" "ecs_to_database" {
  description              = "ECS tasks to PostgreSQL"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.ecs_security_group_id
  source_security_group_id = aws_security_group.database.id
}

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.project_name}-${var.environment}-rds-monitoring"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "tradecore" {
  identifier = "${var.project_name}-${var.environment}-rds"

  engine                = "postgres"
  engine_version        = "15"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.tradecore.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring[0].arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  iam_database_authentication_enabled   = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  apply_immediately   = false
  deletion_protection = true

  skip_final_snapshot       = false
  final_snapshot_identifier = var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.project_name}-${var.environment}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds"
    }
  )
}
