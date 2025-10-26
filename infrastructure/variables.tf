# Infrastructure Variables - VPC is referenced from network project
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "multi-tier-app"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancers"
  type        = bool
  default     = false
}

# Port Configuration
variable "http_port" {
  description = "HTTP port for web servers"
  type        = number
  default     = 80
}

variable "tcp_port" {
  description = "TCP port for backend services"
  type        = number
  default     = 8080
}

variable "udp_port" {
  description = "UDP port for backend services"
  type        = number
  default     = 8443
}

variable "elb_port" {
  description = "Port for the application load balancer listener"
  type        = number
  default     = 80
}

variable "management_port" {
  description = "Port for load balancer health checks"
  type        = number
  default     = 80
}

# Instance Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Port Variables - Keep for backwards compatibility
variable "webserver_sg" {
  description = "OBSOLETE: Security group for web servers (now created by Terraform)"
  type        = string
  default     = ""
}

variable "tcpserver_sg" {
  description = "OBSOLETE: Security group for TCP servers (now created by Terraform)"
  type        = string
  default     = ""
}

variable "udpserver_sg" {
  description = "OBSOLETE: Security group for UDP servers (now created by Terraform)"
  type        = string
  default     = ""
}

variable "elb_sg" {
  description = "OBSOLETE: Security group for ELB (now created by Terraform)"
  type        = string
  default     = ""
}

variable "tcp_client_instance_id" {
  description = "OBSOLETE: Instance ID for the TCP client (now created by Terraform)"
  type        = string
  default     = ""
}

variable "udp_client_instance_id" {
  description = "OBSOLETE: Instance ID for the UDP client (now created by Terraform)"
  type        = string
  default     = ""
}

variable "tcp_server_instance_id" {
  description = "OBSOLETE: Instance ID for the TCP server backend (now created by Terraform)"
  type        = string
  default     = ""
}

variable "udp_server_instance_id" {
  description = "OBSOLETE: Instance ID for the UDP server backend (now created by Terraform)"
  type        = string
  default     = ""
}

variable "app_lb" {
  description = "OBSOLETE: Name of the Application Load Balancer (now created by Terraform)"
  type        = string
  default     = ""
}

variable "network_lb" {
  description = "OBSOLETE: Name of the Network Load Balancer (now created by Terraform)"
  type        = string
  default     = ""
}

variable "target_group_customers" {
  description = "OBSOLETE: Name of the customers target group for ALB (now created by Terraform)"
  type        = string
  default     = ""
}

variable "target_group_orders" {
  description = "OBSOLETE: Name of the orders target group for ALB (now created by Terraform)"
  type        = string
  default     = ""
}

variable "target_group_tcp_servers" {
  description = "OBSOLETE: Name of the TCP servers target group for NLB (now created by Terraform)"
  type        = string
  default     = ""
}

variable "target_group_udp_servers" {
  description = "OBSOLETE: Name of the UDP servers target group for NLB (now created by Terraform)"
  type        = string
  default     = ""
}
