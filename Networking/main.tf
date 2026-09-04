#Tradecore VPC
resource "aws_vpc" "tradecore" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tradecore-${var.environment}"
  }
}

resource "aws_internet_gateway" "tradecore" {
  vpc_id = aws_vpc.tradecore.id

  tags = {
    Name = "tradecore-igw"
  }
}

# Public subnets (2 public subnets in 2 AZs)
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.tradecore.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "tradecore-public-${var.availability_zones[count.index]}"
    Type = "Public"
  }
}

# Private subnets (for  Database)
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.tradecore.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + (length(var.availability_zones)))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "tradecore-private-${var.availability_zones[count.index]}"
    Type = "Private"
  }
}

#Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tradecore.id

  tags = {
    Name = "tradecore-public-rt"
    Type = "Public"
  }
}

# internet route
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tradecore.id
}

# Private route table, both public and private subnets are inside the same VPC, and the VPC automatically has a local route that allows private communication between its CIDR ranges.
resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.tradecore.id

  tags = {
    Name = "tradecore-private-rt-${var.availability_zones[count.index]}"
    Type = "Private"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with their corresponding private route tables
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
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
