# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------

# Create Internet ALB Security Group
resource "aws_security_group" "internet_alb" {
  name   = "${var.prefix}-internet-alb-sg"
  vpc_id = var.internet_vpc_id

  ingress {
    from_port   = var.internet_alb_lis_port
    to_port     = var.internet_alb_lis_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}-internet-alb-sg"
    Environment = var.environment
  }
}

# Create Workload ALB Security Group
resource "aws_security_group" "workload_alb" {
  name   = "${var.prefix}-workload-alb-sg"
  vpc_id = var.workload_vpc_id

  ingress {
    from_port   = var.workload_alb_lis_port
    to_port     = var.workload_alb_lis_port
    protocol    = "tcp"
    cidr_blocks = [var.internet_cidr, var.workload_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}-workload-alb-sg"
    Environment = var.environment
  }
}

# Create ECS Security Group
resource "aws_security_group" "ecs" {
  name   = "${var.prefix}-ecs-sg"
  vpc_id = var.workload_vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.workload_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}-ecs-sg"
    Environment = var.environment
  }
}

# Create Aurora Security Group
resource "aws_security_group" "aurora" {
  name   = "${var.prefix}-aurora-sg"
  vpc_id = var.workload_vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}-aurora-sg"
    Environment = var.environment
  }
}
