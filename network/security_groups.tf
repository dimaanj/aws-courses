# Security Groups for Multi-Tier Application

# Security Group for Load Balancers (ALB and NLB)
resource "aws_security_group" "elb" {
  name        = "${var.project_name}-elb-sg"
  description = "Security group for Application and Network Load Balancers"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP from internet to ALB
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS from internet to ALB
  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound TCP from web servers to NLB
  ingress {
    description     = "Allow TCP from web servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  # Allow inbound UDP from web servers to NLB
  ingress {
    description     = "Allow UDP from web servers"
    from_port       = 8443
    to_port         = 8443
    protocol        = "udp"
    security_groups = [aws_security_group.webserver.id]
  }

  # Allow outbound to web servers from ALB
  egress {
    description     = "Allow outbound to web servers"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  # Allow outbound to backend services from NLB
  egress {
    description     = "Allow outbound to TCP backend services"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.tcpserver.id]
  }

  egress {
    description     = "Allow outbound to UDP backend services"
    from_port       = 8443
    to_port         = 8443
    protocol        = "udp"
    security_groups = [aws_security_group.udpserver.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-elb-sg"
    Type = "Load Balancer"
  }
}

# Security Group for Web Servers
resource "aws_security_group" "webserver" {
  name        = "${var.project_name}-webserver-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP from ALB
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow inbound HTTPS from ALB
  ingress {
    description     = "Allow HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow inbound for health checks from ALB
  ingress {
    description     = "Allow health checks from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow outbound to NLB (TCP)
  egress {
    description     = "Allow TCP to NLB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow outbound to NLB (UDP)
  egress {
    description     = "Allow UDP to NLB"
    from_port       = 8443
    to_port         = 8443
    protocol        = "udp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow outbound HTTPS for external API calls
  egress {
    description = "Allow HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-webserver-sg"
    Type = "Web Server"
  }
}

# Security Group for TCP Backend Services
resource "aws_security_group" "tcpserver" {
  name        = "${var.project_name}-tcpserver-sg"
  description = "Security group for TCP backend services"
  vpc_id      = aws_vpc.main.id

  # Allow inbound TCP from NLB
  ingress {
    description     = "Allow TCP from NLB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow inbound for health checks from NLB
  ingress {
    description     = "Allow health checks from NLB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow outbound HTTPS for external API calls
  egress {
    description = "Allow HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-tcpserver-sg"
    Type = "Backend TCP"
  }
}

# Security Group for UDP Backend Services
resource "aws_security_group" "udpserver" {
  name        = "${var.project_name}-udpserver-sg"
  description = "Security group for UDP backend services"
  vpc_id      = aws_vpc.main.id

  # Allow inbound UDP from NLB
  ingress {
    description     = "Allow UDP from NLB"
    from_port       = 8443
    to_port         = 8443
    protocol        = "udp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow inbound for health checks from NLB
  ingress {
    description     = "Allow health checks from NLB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
  }

  # Allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-udpserver-sg"
    Type = "Backend UDP"
  }
}

