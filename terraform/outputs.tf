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

output "all_vpc_subnets" {
  value = {
    for key, module_instance in module.vpc_private_subnets :
    key => module_instance.private_subnet_ids
  }
}

# Output specific values from all modules
output "all_vpc_ids" {
  value = [
    for module_instance in module.vpc_private_subnets :
    module_instance.vpc_id
  ]
}

output "vpc_configuration" {
  value = {
    for idx, module_instance in module.vpc_private_subnets : idx => {
      vpc_id         = module_instance.vpc_id
      subnet_details = module_instance.subnet_details
    }
  }
}

# Write outputs to file
resource "local_file" "outputs_json" {
  filename = "${path.module}/generated-outputs.json"
  content = jsonencode({
    vpc_configuration = {
      for idx, module_instance in module.vpc_private_subnets : idx => {
        vpc_id         = module_instance.vpc_id
        subnet_details = module_instance.subnet_details
      }
    }
    generated_at = timestamp()
  })
}