# =========================================================
# TRADECORE NETWORKING
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
      Layer       = "Networking"
    }
  )
}

# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

resource "aws_vpc" "tradecore" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

# ---------------------------------------------------------
# INTERNET GATEWAY
# ---------------------------------------------------------

resource "aws_internet_gateway" "tradecore" {
  vpc_id = aws_vpc.tradecore.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# ---------------------------------------------------------
# PUBLIC SUBNETS (2 AZs)
# ---------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.tradecore.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
      Type = "Public"
    }
  )
}

# ---------------------------------------------------------
# PRIVATE SUBNETS (2 AZs - Database)
# ---------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.tradecore.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
      Type = "Private"
    }
  )
}

# ---------------------------------------------------------
# PUBLIC ROUTE TABLE
# ---------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tradecore.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
      Type = "Public"
    }
  )
}

# ---------------------------------------------------------
# PUBLIC ROUTE - INTERNET
# ---------------------------------------------------------

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tradecore.id
}

# ---------------------------------------------------------
# PRIVATE ROUTE TABLES (1 per AZ)
# ---------------------------------------------------------

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.tradecore.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt-${var.availability_zones[count.index]}"
      Type = "Private"
    }
  )
}

# ---------------------------------------------------------
# PUBLIC SUBNET ASSOCIATIONS
# ---------------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------
# PRIVATE SUBNET ASSOCIATIONS
# ---------------------------------------------------------

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
