variable "vpc_id" {
  description = "The VPC ID that contains all resources"
  type        = string
  default     = ""
}

variable "webserver_sg" {
  description = "Security group for web servers"
  type        = string
  default     = ""
}

variable "tcpserver_sg" {
  description = "Security group for TCP servers"
  type        = string
  default     = ""
}

variable "udpserver_sg" {
  description = "Security group for UDP servers"
  type        = string
  default     = ""
}

variable "elb_sg" {
  description = "Security group for ELB"
  type        = string
  default     = ""
}

variable "tcp_client_instance_id" {
  description = "Instance ID for the TCP client (handles /customers requests)"
  type        = string
  default     = ""
}

variable "udp_client_instance_id" {
  description = "Instance ID for the UDP client (handles /orders requests)"
  type        = string
  default     = ""
}

variable "tcp_server_instance_id" {
  description = "Instance ID for the TCP server backend"
  type        = string
  default     = ""
}

variable "udp_server_instance_id" {
  description = "Instance ID for the UDP server backend"
  type        = string
  default     = ""
}

variable "app_lb" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = ""
}

variable "network_lb" {
  description = "Name of the Network Load Balancer"
  type        = string
  default     = ""
}

variable "target_group_customers" {
  description = "Name of the customers target group for ALB"
  type        = string
  default     = ""
}

variable "target_group_orders" {
  description = "Name of the orders target group for ALB"
  type        = string
  default     = ""
}

variable "target_group_tcp_servers" {
  description = "Name of the TCP servers target group for NLB"
  type        = string
  default     = ""
}

variable "target_group_udp_servers" {
  description = "Name of the UDP servers target group for NLB"
  type        = string
  default     = ""
}

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

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

