# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------

# Create ECS Task Execution Role
resource "aws_iam_role" "ecs_exec" {
  name = "${var.prefix}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "${var.prefix}-ecs-exec-role"
    Environment = var.environment
  }
}

# Create Policy Attachment to ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.prefix}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.prefix}-ecs-logs"
    Environment = var.environment
  }
}

# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

  tags = {
    Name        = "${var.prefix}-cluster"
    Environment = var.environment
  }
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "echoserver" {
  family                   = "${var.prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_exec.arn

  container_definitions = jsonencode([{
    name      = "${var.prefix}-container"
    image     = var.container_image
    essential = true

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "echoserver"
      }
    }
  }])

  tags = {
    Name        = "${var.prefix}-task"
    Environment = var.environment
  }
}

# Create ECS Service
resource "aws_ecs_service" "echoserver" {
  name                              = "${var.prefix}-service"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.echoserver.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = [var.app_a_id, var.app_b_id]
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.workload_alb_tg_arn
    container_name   = "${var.prefix}-container"
    container_port   = 8080
  }

  tags = {
    Name        = "${var.prefix}-service"
    Environment = var.environment
  }
}