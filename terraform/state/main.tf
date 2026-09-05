# =========================================================
# TRADECORE - TERRAFORM STATE INFRASTRUCTURE
# =========================================================
# S3 bucket for remote state + DynamoDB table for locking.
# Bootstrap with:
#   terraform init -backend=false
#   terraform apply -target=module.state
#   terraform init -migrate-state
# =========================================================

# ---------------------------------------------------------
# S3 BUCKET - REMOTE STATE
# ---------------------------------------------------------

resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.project_name}-${var.environment}-tfstate"

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-tfstate"
    Purpose   = "Terraform remote state"
    ManagedBy = "Terraform"
  })
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------
# DYNAMODB TABLE - STATE LOCKING
# ---------------------------------------------------------

resource "aws_dynamodb_table" "tflock" {
  name         = "${var.project_name}-${var.environment}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-tflock"
    Purpose   = "Terraform state locking"
    ManagedBy = "Terraform"
  })
}
