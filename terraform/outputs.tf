output "vpc_prefix_name" {
  description = "VPC Prefix Name"
  value       = var.vpc_prefix_name
}

output "environment_name" {
  description = "Environment Name"
  value       = var.environment_name
}

output "vpc_cidrs" {
  description = "VPC CIDR blocks"
  value       = var.vpc_cidrs
}

output "subnet_prefix" {
  description = "Subnet Prefix"
  value       = var.subnet_prefix
}
