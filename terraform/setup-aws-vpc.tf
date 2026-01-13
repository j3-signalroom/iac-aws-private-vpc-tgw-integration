module "vpc_private_subnets" {
  for_each          = { for index, cidr in tolist(toset(split(",", var.vpc_cidrs))) : index => cidr }

  source            = "./vpc_private_subnets"

  vpc_cidr          = each.value
  subnet_count      = var.subnet_count
  vpc_name          = "${var.vpc_prefix_name}-${var.environment_name}-${each.key}"
  environment_name  = var.environment_name
  new_bits           = local.newbits
}
