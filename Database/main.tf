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

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-database-sg"
      Tier = "Database"
    }
  )
}

resource "aws_db_instance" "tradecore" {
  identifier = "${var.project_name}-${var.environment}-rds"

  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp3"
  storage_encrypted    = true

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
  monitoring_interval     = 0
  apply_immediately       = false
  deletion_protection     = true

  skip_final_snapshot       = false
  final_snapshot_identifier = var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.project_name}-${var.environment}-final-snapshot"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds"
    }
  )
}
