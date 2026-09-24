data "aws_caller_identity" "current" {}

locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Observability"
    }
  )

  # Alarms still fire without a subscriber; wiring one is a one-line change.
  alarm_emails = var.budget_alert_emails

  # aws_lb.id and aws_lb_target_group.id are ARNs, but the CloudWatch
  # dimensions want the short form (app/name/id, targetgroup/name/id).
  # Passing the ARN silently yields no datapoints, so the alarm never fires.
  alb_id_short       = element(split("loadbalancer/", var.alb_id), 1)
  target_group_short = element(split("targetgroup/", var.target_group_id), 1)
}

resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"

  # SNS encryption at rest (AWS-managed key).
  kms_master_key_id = "alias/aws/sns"

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "alarms" {
  count = length(local.alarm_emails)

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = local.alarm_emails[count.index]
}

locals {
  alarm_actions = length(local.alarm_emails) > 0 ? [aws_sns_topic.alarms.arn] : []
}

# HTTP 5xx from the load balancer means users are seeing errors right now.
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  alarm_description   = "ALB returned one or more 5xx responses"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_id_short
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions

  tags = local.common_tags
}

# A dead target means traffic is being served errors before it reaches the app.
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  alarm_description   = "ALB has an unhealthy target"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_id_short
    TargetGroup  = local.target_group_short
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions

  tags = local.common_tags
}

# Tasks that fail to start never register a target, so the target alarm above
# can miss it; this watches the service directly.
resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  alarm_name        = "${var.project_name}-${var.environment}-ecs-running-tasks"
  alarm_description = "Fewer tasks running than the service expects"
  # Container Insights publishes this under ECS/ContainerInsights, not AWS/ECS.
  # Using the wrong namespace yields no datapoints, which with missing-data set
  # to breaching leaves the alarm stuck permanently in ALARM.
  namespace   = "ECS/ContainerInsights"
  metric_name = "RunningTaskCount"
  statistic   = "Average"
  period      = 60
  # Rolling deployments briefly dip below desired (min healthy is 50%), so a
  # 3-minute breach window would page on every deploy; 5 minutes does not.
  evaluation_periods  = 5
  threshold           = var.ecs_desired_count
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu"
  alarm_description   = "RDS CPU sustained above 80%"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-free-storage"
  alarm_description   = "RDS free storage below 1.5 GB"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 1610612736 # 1.5 GB
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions

  tags = local.common_tags
}

# ── Audit trail + access logs ─────────────────────────────────────────
# One log bucket serves CloudTrail and ALB access logs (separate prefixes).
# Bucket name mirrors the module naming convention so the ALB module can
# reference it without creating a module dependency cycle (see root locals).
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.project_name}-${var.environment}-logs"
  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ELB account for af-south-1 (regional, documented by AWS).
locals {
  elb_service_account_arn = "arn:aws:iam::098369216593:root"
  aws_account_id          = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs.arn}/cloudtrail/AWSLogs/${local.aws_account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = { AWS = local.elb_service_account_arn }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs.arn}/alb/AWSLogs/${local.aws_account_id}/*"
      },
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = { AWS = local.elb_service_account_arn }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.logs.arn
      }
    ]
  })
}

resource "aws_cloudtrail" "project" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true

  tags = local.common_tags
}

resource "aws_budgets_budget" "project" {
  name              = "${var.project_name}-${var.environment}"
  budget_type       = "COST"
  limit_amount      = var.budget_limit_usd
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  dynamic "notification" {
    for_each = length(local.alarm_emails) > 0 ? [80, 100] : []

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = local.alarm_emails
    }
  }

  dynamic "notification" {
    for_each = length(local.alarm_emails) > 0 ? [100] : []

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = local.alarm_emails
    }
  }
}
