output "app_lb_dns" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "network_lb_dns" {
  description = "DNS name of the network load balancer"
  value       = aws_lb.network_lb.dns_name
}

output "customers_url" {
  description = "URL to access customers service"
  value       = "http://${aws_lb.app_lb.dns_name}/customers"
}

output "orders_url" {
  description = "URL to access orders service"
  value       = "http://${aws_lb.app_lb.dns_name}/orders"
}

output "root_url" {
  description = "URL to test the default redirect"
  value       = "http://${aws_lb.app_lb.dns_name}/"
}

# EC2 Instance IDs
output "web_server_instance_ids" {
  description = "Instance IDs of the web servers"
  value = {
    customers = aws_instance.tcp_client.id
    orders    = aws_instance.udp_client.id
  }
}

output "backend_service_instance_ids" {
  description = "Instance IDs of the backend services"
  value = {
    tcp_server = aws_instance.tcp_server.id
    udp_server = aws_instance.udp_server.id
  }
}

# Security Group IDs (from network project via remote state)
output "security_group_ids" {
  description = "Security group IDs from network project"
  value       = data.terraform_remote_state.network.outputs.security_group_ids
}

# Target Group ARNs
output "target_group_arns" {
  description = "Target group ARNs"
  value = {
    customers    = aws_lb_target_group.customers.arn
    orders       = aws_lb_target_group.orders.arn
    tcp_servers  = aws_lb_target_group.tcp_servers.arn
    udp_servers  = aws_lb_target_group.udp_servers.arn
  }
}

