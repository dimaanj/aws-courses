output "app_lb_dns" {
  description = "DNS name of the application load balancer"
  value       = data.aws_lb.app_lb.dns_name
}

output "network_lb_dns" {
  description = "DNS name of the network load balancer"
  value       = data.aws_lb.network_lb.dns_name
}

output "customers_url" {
  description = "URL to access customers service"
  value       = "http://${data.aws_lb.app_lb.dns_name}/customers"
}

output "orders_url" {
  description = "URL to access orders service"
  value       = "http://${data.aws_lb.app_lb.dns_name}/orders"
}

output "root_url" {
  description = "URL to test the default redirect"
  value       = "http://${data.aws_lb.app_lb.dns_name}/"
}

