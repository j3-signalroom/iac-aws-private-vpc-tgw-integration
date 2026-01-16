module "vpc_private_subnets" {
  for_each          = { for index, cidr in local.vpc_list : index => cidr }

  source            = "./vpc_private_subnets"

  vpc_cidr          = each.value
  subnet_count      = var.subnet_count
  vpc_name          = "${var.vpc_prefix_name}-${var.environment_name}-${each.key}"
  environment_name  = var.environment_name
  new_bits          = local.newbits

  transit_gateway_id             = var.transit_gateway_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  vpn_client_cidr                = var.vpn_client_cidr
}
