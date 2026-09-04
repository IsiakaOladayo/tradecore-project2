
# TradeCore RDS PostgreSQL

resource "aws_db_subnet_group" "tradecore" {
  name = "tradecore-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "tradecore-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}



# RDS PostgreSQL 17

resource "aws_db_instance" "tradecore" {
  identifier = "tradecore-${var.environment}-db"

  # PostgreSQL 17
  engine         = "postgres"
  engine_version = "17"

  # Free-Tier eligible class
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
  storage_encrypted = true

  # Network
  db_subnet_group_name   = aws_db_subnet_group.tradecore.name
  vpc_security_group_ids = [var.database_security_group_id]

  # IMPORTANT:
  # Database is NOT reachable directly from the internet.
  publicly_accessible = false

  # Single-AZ
  multi_az = false

  # Automated backups
  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  # Maintenance
  maintenance_window = "sun:03:00-sun:04:00"

  # Monitoring
  monitoring_interval = 0

  # Do not automatically apply modifications immediately
  apply_immediately = false

  # Production safety
  deletion_protection = true

  # Final snapshot when Terraform destroys the instance
  skip_final_snapshot = false

  tags = {
    Name        = "tradecore-${var.environment}-rds"
    Environment = var.environment
  }
}

# TradeCore Database Security Group

resource "aws_security_group" "database" {
  name        = "tradecore-${var.environment}-database-sg"
  description = "Security group for TradeCore RDS PostgreSQL"
  vpc_id      = aws_vpc.tradecore.id

  # PostgreSQL access ONLY from ECS
  ingress {
    description     = "PostgreSQL access from ECS"
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

