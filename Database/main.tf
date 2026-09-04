# TradeCore RDS PostgreSQL

# DB SUBNET GROUP

resource "aws_db_subnet_group" "tradecore" {
  name = "tradecore-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "tradecore-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}


# DATABASE SECURITY GROUP

resource "aws_security_group" "database" {
  name        = "tradecore-${var.environment}-database-sg"
  description = "Security group for TradeCore RDS PostgreSQL"
  vpc_id      = var.vpc_id

  # PostgreSQL access ONLY from ECS
  ingress {
    description     = "PostgreSQL access from ECS only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tradecore-${var.environment}-database-sg"
    Environment = var.environment
    Tier        = "Database"
  }
}


# RDS POSTGRESQL 17

resource "aws_db_instance" "tradecore" {
  identifier = "tradecore-${var.environment}-db"

  # PostgreSQL
  engine         = "postgres"
  engine_version = "17"

  # Instance
  instance_class = "db.t3.micro"

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Encryption
  # Uses the AWS-managed/default RDS encryption key
  storage_encrypted = true

  # Network
  db_subnet_group_name   = aws_db_subnet_group.tradecore.name
  vpc_security_group_ids = [aws_security_group.database.id]

  # No direct internet access
  publicly_accessible = false

  # Single-AZ
  multi_az = false

  # Automated backups
  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  # Maintenance
  maintenance_window = "sun:03:00-sun:04:00"

  # Enhanced monitoring disabled
  monitoring_interval = 0

  # Do not immediately apply modifications
  apply_immediately = false

  # Production safety
  deletion_protection = true

  # Take final snapshot before destruction
  skip_final_snapshot = false

  tags = {
    Name        = "tradecore-${var.environment}-rds"
    Environment = var.environment
  }
}
