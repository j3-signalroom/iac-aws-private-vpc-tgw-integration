output "vpc_name" {
  description = "VPC Name"
  value       = var.vpc_name
}

output "environment_name" {
  description = "Environment Name"
  value       = var.environment_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "subnet_prefix" {
  description = "Subnet Prefix"
  value       = var.subnet_prefix
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of all private subnet CIDRs"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_azs" {
  description = "List of availability zones for private subnets"
  value       = aws_subnet.private[*].availability_zone
}

output "route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}

output "route_table_association_ids" {
  description = "List of route table association IDs"
  value       = aws_route_table_association.private[*].id
}

output "subnet_map" {
  description = "Map of subnet names to IDs"
  value = {
    for index, subnet in aws_subnet.private : 
    "${var.vpc_name}-${var.environment_name}-private-subnet-${index + 1}" => subnet.id
  }
}

output "subnet_details" {
  description = "Detailed information about all subnets"
  value = [
    for index, subnet in aws_subnet.private : {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      name              = "${var.vpc_name}-${var.environment_name}-private-subnet-${index + 1}"
    }
  ]
}