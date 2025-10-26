# Multi-Tier Application Load Balancer Configuration

This Terraform configuration sets up load balancers for a multi-tier application architecture in AWS.

## Architecture Overview

The setup includes:

1. **Application Load Balancer (ALB)**: Internet-facing load balancer that routes traffic to web servers
2. **Network Load Balancer (NLB)**: Internal load balancer that routes TCP/UDP traffic to backend services
3. **Web Servers**: Handle customer and orders requests
4. **Backend Services**: Handle TCP and UDP traffic

## Components

### Load Balancers
- `${app_lb}`: Application Load Balancer
- `${network_lb}`: Network Load Balancer (internal)

### Target Groups for ALB
- `${target_group_customers}`: For /customers requests
- `${target_group_orders}`: For /orders requests

### Target Groups for NLB
- `${target_group_tcp_servers}`: For TCP traffic
- `${target_group_udp_servers}`: For UDP traffic

### EC2 Instances
- **Web Servers:**
  - `${tcp_client_instance_id}`: Handles /customers requests
  - `${udp_client_instance_id}`: Handles /orders requests

- **Backend Services:**
  - `${tcp_server_instance_id}`: Handles TCP traffic
  - `${udp_server_instance_id}`: Handles UDP traffic

## Configuration

### ALB Listener Rules
- **Path: /customers** → Forwards to customers target group (priority 100)
- **Path: /orders** → Forwards to orders target group (priority 200)
- **Default (all other paths)** → Redirects to /orders with HTTP 302 (priority 500)

### NLB Listeners
- **TCP Port** (${tcp_port}): Forwards to TCP servers target group
- **UDP Port** (${udp_port}): Forwards to UDP servers target group

## Setup Instructions

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual AWS resource IDs and names.

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Documentation

For detailed information and diagrams:
- **ARCHITECTURE_DIAGRAM.md**: Mermaid diagram and technical deep dive
- **CONCEPTS.md**: Simplified explanations of key concepts for software engineers
- **ARCHITECTURE.md**: ASCII diagram of the traffic flow

## Verification

After applying the configuration, verify the setup:

1. **Customers service:**
   ```bash
   curl http://${app_lb_dns}/customers
   ```

2. **Orders service:**
   ```bash
   curl http://${app_lb_dns}/orders
   ```

3. **Default redirect:**
   ```bash
   curl -I http://${app_lb_dns}/
   # Should return HTTP 302 redirect to /orders
   ```

## Outputs

The configuration will output:
- `app_lb_dns`: DNS name of the application load balancer
- `network_lb_dns`: DNS name of the network load balancer
- `customers_url`: Full URL for customers service
- `orders_url`: Full URL for orders service
- `root_url`: Root URL that redirects to /orders

## Requirements

- Terraform >= 0.14
- AWS provider configured with appropriate credentials
- Existing resources (VPC, EC2 instances, load balancers, target groups, security groups)

