# Data sources to get existing resources
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_security_group" "webserver" {
  id = var.webserver_sg
}

data "aws_security_group" "tcpserver" {
  id = var.tcpserver_sg
}

data "aws_security_group" "udpserver" {
  id = var.udpserver_sg
}

data "aws_security_group" "elb" {
  id = var.elb_sg
}

data "aws_ec2_instance" "tcp_client" {
  instance_id = var.tcp_client_instance_id
}

data "aws_ec2_instance" "udp_client" {
  instance_id = var.udp_client_instance_id
}

data "aws_ec2_instance" "tcp_server" {
  instance_id = var.tcp_server_instance_id
}

data "aws_ec2_instance" "udp_server" {
  instance_id = var.udp_server_instance_id
}

data "aws_lb" "app_lb" {
  name = var.app_lb
}

data "aws_lb" "network_lb" {
  name = var.network_lb
}

data "aws_lb_target_group" "target_group_customers" {
  name = var.target_group_customers
}

data "aws_lb_target_group" "target_group_orders" {
  name = var.target_group_orders
}

data "aws_lb_target_group" "target_group_tcp_servers" {
  name = var.target_group_tcp_servers
}

data "aws_lb_target_group" "target_group_udp_servers" {
  name = var.target_group_udp_servers
}

# Target Group Attachments
# Attach web servers to ALB target groups
resource "aws_lb_target_group_attachment" "customers_web_server" {
  target_group_arn = data.aws_lb_target_group.target_group_customers.arn
  target_id        = data.aws_ec2_instance.tcp_client.instance_id
  port             = var.http_port
}

resource "aws_lb_target_group_attachment" "orders_web_server" {
  target_group_arn = data.aws_lb_target_group.target_group_orders.arn
  target_id        = data.aws_ec2_instance.udp_client.instance_id
  port             = var.http_port
}

# Attach backend servers to NLB target groups
# TCP traffic goes to both backend services (Customers and Orders)
resource "aws_lb_target_group_attachment" "tcp_backend_customers" {
  target_group_arn = data.aws_lb_target_group.target_group_tcp_servers.arn
  target_id        = data.aws_ec2_instance.tcp_server.instance_id
  port             = var.tcp_port
}

resource "aws_lb_target_group_attachment" "tcp_backend_orders" {
  target_group_arn = data.aws_lb_target_group.target_group_tcp_servers.arn
  target_id        = data.aws_ec2_instance.udp_server.instance_id
  port             = var.tcp_port
}

# UDP traffic goes to both backend services (Customers and Orders)
resource "aws_lb_target_group_attachment" "udp_backend_customers" {
  target_group_arn = data.aws_lb_target_group.target_group_udp_servers.arn
  target_id        = data.aws_ec2_instance.tcp_server.instance_id
  port             = var.udp_port
}

resource "aws_lb_target_group_attachment" "udp_backend_orders" {
  target_group_arn = data.aws_lb_target_group.target_group_udp_servers.arn
  target_id        = data.aws_ec2_instance.udp_server.instance_id
  port             = var.udp_port
}

# Application Load Balancer Listener Configuration
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = data.aws_lb.app_lb.arn
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

# Custom action for /customers path
resource "aws_lb_listener_rule" "customers_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.target_group_customers.arn
  }

  condition {
    path_pattern {
      values = ["/customers", "/customers/*"]
    }
  }
}

# Custom action for /orders path
resource "aws_lb_listener_rule" "orders_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.target_group_orders.arn
  }

  condition {
    path_pattern {
      values = ["/orders", "/orders/*"]
    }
  }
}

# Network Load Balancer TCP Listener
resource "aws_lb_listener" "network_lb_tcp_listener" {
  load_balancer_arn = data.aws_lb.network_lb.arn
  port               = var.tcp_port
  protocol           = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.target_group_tcp_servers.arn
  }
}

# Network Load Balancer UDP Listener
resource "aws_lb_listener" "network_lb_udp_listener" {
  load_balancer_arn = data.aws_lb.network_lb.arn
  port               = var.udp_port
  protocol           = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.target_group_udp_servers.arn
  }
}

