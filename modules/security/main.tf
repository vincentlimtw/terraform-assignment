# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------

# Create Internet ALB Security Group
resource "aws_security_group" "internet_alb" {
  name   = "${var.prefix}-internet-alb-sg"
  vpc_id = var.internet_vpc_id

  tags = {
    Name        = "${var.prefix}-internet-alb-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "internet_alb" {
  security_group_id = aws_security_group.internet_alb.id
  from_port         = var.internet_alb_lis_port
  to_port           = var.internet_alb_lis_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "internet_alb" {
  security_group_id = aws_security_group.internet_alb.id
  from_port         = var.workload_nlb_lis_port
  to_port           = var.workload_nlb_lis_port
  ip_protocol       = "tcp"
  cidr_ipv4         = var.workload_vpc_cidr
}

# Create Workload ALB Security Group
resource "aws_security_group" "workload_alb" {
  name   = "${var.prefix}-workload-alb-sg"
  vpc_id = var.workload_vpc_id

  tags = {
    Name        = "${var.prefix}-workload-alb-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "workload_alb" {
  security_group_id = aws_security_group.workload_alb.id
  from_port         = var.workload_alb_lis_port
  to_port           = var.workload_alb_lis_port
  ip_protocol       = "tcp"
  cidr_ipv4         = var.internet_vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "workload_alb" {
  security_group_id            = aws_security_group.workload_alb.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
}

# Create ECS Security Group
resource "aws_security_group" "ecs" {
  name   = "${var.prefix}-ecs-sg"
  vpc_id = var.workload_vpc_id

  tags = {
    Name        = "${var.prefix}-ecs-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.workload_alb.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.aurora.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

# Create Aurora Security Group
resource "aws_security_group" "aurora" {
  name   = "${var.prefix}-aurora-sg"
  vpc_id = var.workload_vpc_id

  tags = {
    Name        = "${var.prefix}-aurora-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "aurora" {
  security_group_id            = aws_security_group.aurora.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}