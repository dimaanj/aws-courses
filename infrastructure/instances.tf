# Customers Web Server (tcp_client)
resource "aws_instance" "tcp_client" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [data.aws_security_group.webserver.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              
              # Create a simple HTTP server that handles /customers requests
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head><title>Customers Web Server</title></head>
              <body>
                <h1>Customers Service</h1>
                <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
                <p>This server handles /customers requests</p>
              </body>
              </html>
              HTML
              
              cat > /var/www/html/customers/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head><title>Customers Service</title></head>
              <body>
                <h1>Customers Service Response</h1>
                <p>This is the Customers service endpoint</p>
              </body>
              </html>
              HTML
              
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.project_name}-tcp-client"
    Type = "Web Server"
    Role = "Customers"
  }
}

# Orders Web Server (udp_client)
resource "aws_instance" "udp_client" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.public.ids[1]
  vpc_security_group_ids = [data.aws_security_group.webserver.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              
              # Create a simple HTTP server that handles /orders requests
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head><title>Orders Web Server</title></head>
              <body>
                <h1>Orders Service</h1>
                <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
                <p>This server handles /orders requests</p>
              </body>
              </html>
              HTML
              
              cat > /var/www/html/orders/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head><title>Orders Service</title></head>
              <body>
                <h1>Orders Service Response</h1>
                <p>This is the Orders service endpoint</p>
              </body>
              </html>
              HTML
              
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.project_name}-udp-client"
    Type = "Web Server"
    Role = "Orders"
  }
}

# TCP Backend Service (tcp_server)
resource "aws_instance" "tcp_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [data.aws_security_group.tcpserver.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              
              # Create a simple nginx server for TCP traffic
              cat > /etc/nginx/nginx.conf <<'NGINX'
              events {}
              http {
                  server {
                      listen 80;
                      location / {
                          return 200 "TCP Backend Service - Customers Service";
                          add_header Content-Type text/plain;
                      }
                      location /health {
                          return 200 "healthy";
                          add_header Content-Type text/plain;
                      }
                  }
              }
              NGINX
              
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "${var.project_name}-tcp-server"
    Type = "Backend Service"
    Role = "Customers Backend"
  }
}

# UDP Backend Service (udp_server)
resource "aws_instance" "udp_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.private.ids[1]
  vpc_security_group_ids = [data.aws_security_group.udpserver.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              
              # Create a simple nginx server for UDP traffic
              cat > /etc/nginx/nginx.conf <<'NGINX'
              events {}
              http {
                  server {
                      listen 80;
                      location / {
                          return 200 "UDP Backend Service - Orders Service";
                          add_header Content-Type text/plain;
                      }
                      location /health {
                          return 200 "healthy";
                          add_header Content-Type text/plain;
                      }
                  }
              }
              NGINX
              
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "${var.project_name}-udp-server"
    Type = "Backend Service"
    Role = "Orders Backend"
  }
}

