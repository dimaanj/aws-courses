# Target Groups for Application Load Balancer

# Customers Target Group
resource "aws_lb_target_group" "customers" {
  name     = "${var.project_name}-customers-tg"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 10

  tags = {
    Name = "${var.project_name}-customers-tg"
    Type = "ALB Target Group"
  }
}

# Orders Target Group
resource "aws_lb_target_group" "orders" {
  name     = "${var.project_name}-orders-tg"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 10

  tags = {
    Name = "${var.project_name}-orders-tg"
    Type = "ALB Target Group"
  }
}

# Target Groups for Network Load Balancer

# TCP Servers Target Group
resource "aws_lb_target_group" "tcp_servers" {
  name     = "${var.project_name}-tcp-servers-tg"
  port     = var.tcp_port
  protocol = "TCP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
  }

  deregistration_delay = 10

  tags = {
    Name = "${var.project_name}-tcp-servers-tg"
    Type = "NLB TCP Target Group"
  }
}

# UDP Servers Target Group
resource "aws_lb_target_group" "udp_servers" {
  name     = "${var.project_name}-udp-servers-tg"
  port     = var.udp_port
  protocol = "UDP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
  }

  deregistration_delay = 10

  tags = {
    Name = "${var.project_name}-udp-servers-tg"
    Type = "NLB UDP Target Group"
  }
}

