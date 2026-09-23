locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Compute"
    }
  )

  desired_count = coalesce(
    var.desired_count,
    var.environment == "production" ? 2 : 1
  )

  application_security_group_id = (
    var.application_security_group_id != null
    ? var.application_security_group_id
    : aws_security_group.application[0].id
  )

  secrets_manager_secret_arns = var.secrets_manager_secret_arns
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/ecs/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "/ecs/${var.project_name}/${var.environment}/application"
    }
  )
}

resource "aws_ecs_cluster" "application" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-cluster"
    }
  )
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-execution-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  count = length(local.secrets_manager_secret_arns) > 0 ? 1 : 0

  name = "${var.project_name}-${var.environment}-secrets-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = values(local.secrets_manager_secret_arns)
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_kms" {
  count = var.secrets_kms_key_arn != null ? 1 : 0

  name = "${var.project_name}-${var.environment}-secrets-kms-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "kms:Decrypt"
        ]

        Resource = var.secrets_kms_key_arn
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-role"
    }
  )
}

resource "aws_iam_role_policy" "ecs_exec" {
  count = var.enable_execute_command ? 1 : 0

  name = "${var.project_name}-${var.environment}-ecs-exec"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "application" {
  family = "${var.project_name}-${var.environment}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name = var.container_name

      image = var.container_image

      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_VERSION"
          value = var.app_version
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "NODE_ENV"
          value = var.node_env
        },
        {
          name  = "FRONTEND_URL"
          value = var.frontend_url
        },
        {
          name  = "DB_SSL"
          value = var.db_ssl
        },
        {
          name  = "S3_BUCKET"
          value = var.s3_bucket_name
        }
      ]

      secrets = [
        for env_name, arn in local.secrets_manager_secret_arns : {
          name      = env_name
          valueFrom = arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.application.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -qO- http://localhost:${var.container_port}${var.health_check_path} || exit 1"
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      stopTimeout = 30
    }
  ])

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-task-definition"
    }
  )
}

resource "aws_security_group" "application" {
  count = var.application_security_group_id == null ? 1 : 0

  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "ECS tasks: inbound only from ALB on application port."
  vpc_id      = var.vpc_id

  # No inline rules: mixing inline and standalone styles makes the provider
  # revoke rules it doesn't manage. Split by direction to avoid an ALB↔ECS cycle.

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
    }
  )
}

# Standalone rules; skipped with an external security group. The PostgreSQL
# egress lives in the Database module to avoid a cycle.
resource "aws_security_group_rule" "ingress_from_alb" {
  count = var.application_security_group_id == null ? 1 : 0

  description              = "Application traffic from ALB only"
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application[0].id
  source_security_group_id = var.alb_security_group_id
}

resource "aws_security_group_rule" "egress_https" {
  count = var.application_security_group_id == null ? 1 : 0

  description       = "HTTPS to AWS APIs (ECR, Secrets Manager, CloudWatch, STS). No VPC endpoints are deployed."
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.application[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_dns_udp" {
  count = var.application_security_group_id == null ? 1 : 0

  description       = "DNS to the VPC resolver"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.application[0].id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "egress_dns_tcp" {
  count = var.application_security_group_id == null ? 1 : 0

  description       = "DNS over TCP to the VPC resolver"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.application[0].id
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_ecs_service" "application" {
  name             = var.service_name
  cluster          = aws_ecs_cluster.application.id
  task_definition  = aws_ecs_task_definition.application.arn
  desired_count    = local.desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [local.application_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  health_check_grace_period_seconds = 60

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_iam_role_policy.ecs_task_execution_secrets,
    aws_cloudwatch_log_group.application
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-service"
    }
  )

  lifecycle {
    # Scaled manually outside Terraform; drift here is intentional, not a bug.
    ignore_changes = [
      desired_count
    ]
  }
}
