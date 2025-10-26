# Data sources are in main.tf

# Application Load Balancer (Internet-facing)
resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.elb.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2                = true
  enable_cross_zone_load_balancing = true

  idle_timeout = 60

  tags = {
    Name = "${var.project_name}-app-lb"
    Type = "Application Load Balancer"
  }
}

# Network Load Balancer (Internal)
resource "aws_lb" "network_lb" {
  name               = "${var.project_name}-network-lb"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [data.aws_security_group.elb.id]
  subnets            = data.aws_subnets.private.ids

  enable_deletion_protection = var.enable_deletion_protection

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-network-lb"
    Type = "Network Load Balancer"
  }
}

# Target Group Attachments

# Attach web servers to ALB target groups
resource "aws_lb_target_group_attachment" "customers_web_server" {
  target_group_arn = aws_lb_target_group.customers.arn
  target_id        = aws_instance.tcp_client.id
  port             = var.http_port
}

resource "aws_lb_target_group_attachment" "orders_web_server" {
  target_group_arn = aws_lb_target_group.orders.arn
  target_id        = aws_instance.udp_client.id
  port             = var.http_port
}

# Attach backend servers to NLB target groups
# Both backend services receive both TCP and UDP traffic
resource "aws_lb_target_group_attachment" "tcp_backend_customers" {
  target_group_arn = aws_lb_target_group.tcp_servers.arn
  target_id        = aws_instance.tcp_server.id
  port             = var.tcp_port
}

resource "aws_lb_target_group_attachment" "tcp_backend_orders" {
  target_group_arn = aws_lb_target_group.tcp_servers.arn
  target_id        = aws_instance.udp_server.id
  port             = var.tcp_port
}

resource "aws_lb_target_group_attachment" "udp_backend_customers" {
  target_group_arn = aws_lb_target_group.udp_servers.arn
  target_id        = aws_instance.tcp_server.id
  port             = var.udp_port
}

resource "aws_lb_target_group_attachment" "udp_backend_orders" {
  target_group_arn = aws_lb_target_group.udp_servers.arn
  target_id        = aws_instance.udp_server.id
  port             = var.udp_port
}

# Application Load Balancer Listener
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.elb_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    
    redirect {
      port        = "#{port}"
      protocol    = "#{protocol}"
      status_code = "HTTP_302"
      path        = "/orders"
      query       = "#{query}"
    }
  }
}

# ALB Listener Rules
resource "aws_lb_listener_rule" "customers_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customers.arn
  }

  condition {
    path_pattern {
      values = ["/customers", "/customers/*"]
    }
  }
}

resource "aws_lb_listener_rule" "orders_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }

  condition {
    path_pattern {
      values = ["/orders", "/orders/*"]
    }
  }
}

# Network Load Balancer TCP Listener
resource "aws_lb_listener" "network_lb_tcp_listener" {
  load_balancer_arn = aws_lb.network_lb.arn
  port               = var.tcp_port
  protocol           = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_servers.arn
  }
}

# Network Load Balancer UDP Listener
resource "aws_lb_listener" "network_lb_udp_listener" {
  load_balancer_arn = aws_lb.network_lb.arn
  port               = var.udp_port
  protocol           = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.udp_servers.arn
  }
}

