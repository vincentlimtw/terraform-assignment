# -----------------------------------------------------------------------------
# Load Balancers
# -----------------------------------------------------------------------------

# Create Workload NLB
resource "aws_lb" "nlb" {
  name               = "${var.prefix}-workload-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.web_a_id, var.web_b_id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${var.prefix}-workload-nlb"
    Environment = var.environment
  }
}

# Create Workload NLB Target Group
resource "aws_lb_target_group" "nlb" {
  name        = "${var.prefix}-nlb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.workload_vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create Workload NLB Listener
resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb.arn
  }
}

# Create Workload ALB
resource "aws_lb" "workload_alb" {
  name               = "${var.prefix}-workload-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [var.web_a_id, var.web_b_id]
  security_groups    = [var.workload_alb_sg_id]

  tags = {
    Name        = "${var.prefix}-workload-alb"
    Environment = var.environment
  }
}

# Create Workload ALB Target Group
resource "aws_lb_target_group" "workload_alb" {
  name        = "${var.prefix}-workload-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.workload_vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  deregistration_delay = 30
}

# Create Workload ALB Listener
resource "aws_lb_listener" "workload_alb" {
  load_balancer_arn = aws_lb.workload_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.workload_alb.arn
  }
}

# Attach Workload ALB to NLB Target Group
resource "aws_lb_target_group_attachment" "nlb_to_alb" {
  target_group_arn = aws_lb_target_group.nlb.arn
  target_id        = aws_lb.workload_alb.arn
  port             = 80

  depends_on = [aws_lb_listener.workload_alb]
}

# Wait for NLB to fully provision its ENIs before looking up IPs
resource "time_sleep" "wait_for_nlb" {
  create_duration = "180s"

  depends_on = [aws_lb.nlb]
}

# Map NLB subnets to static keys so for_each count is known before apply
locals {
  nlb_subnet_map = {
    "az1" = var.web_a_id
    "az2" = var.web_b_id
  }
}

# Look up NLB ENI per subnet using static keys
data "aws_network_interface" "nlb_eni" {
  for_each = local.nlb_subnet_map

  filter {
    name   = "description"
    values = ["ELB net/${var.prefix}-workload-nlb/*"]
  }

  filter {
    name   = "subnet-id"
    values = [each.value]
  }

  filter {
    name   = "status"
    values = ["in-use"]
  }

  depends_on = [time_sleep.wait_for_nlb]
}

# Create Internet ALB
resource "aws_lb" "internet_alb" {
  name               = "${var.prefix}-internet-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.gateway_a_id, var.gateway_b_id]
  security_groups    = [var.internet_alb_sg_id]

  tags = {
    Name        = "${var.prefix}-internet-alb"
    Environment = var.environment
  }
}

# Create Internet ALB Target Group
resource "aws_lb_target_group" "internet_alb" {
  name        = "${var.prefix}-internet-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.internet_vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create Internet ALB Listener
resource "aws_lb_listener" "internet_alb" {
  load_balancer_arn = aws_lb.internet_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internet_alb.arn
  }
}

# Attach NLB IPs to Internet ALB Target Group
resource "aws_lb_target_group_attachment" "nlb_eni" {
  for_each = data.aws_network_interface.nlb_eni

  target_group_arn  = aws_lb_target_group.internet_alb.arn
  target_id         = each.value.private_ip
  port              = 80
  availability_zone = "all"
}