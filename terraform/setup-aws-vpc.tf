module "vpc_private_subnets" {
  for_each          = { for index, cidr in local.vpc_list : index => cidr }

  source            = "./vpc_private_subnets"

  vpc_cidr          = each.value
  subnet_count      = var.subnet_count
  vpc_name          = "${var.vpc_prefix_name}-${var.environment_name}-${each.key}"
  environment_name  = var.environment_name
  new_bits          = local.newbits
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  for_each           = { for index, cidr in local.vpc_list : index => cidr }

  subnet_ids         = module.vpc_private_subnets.private_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc_private_subnets.vpc_id

  tags = {
    Name = "app-vpc-attachment"
  }
}

# Associate with route table
resource "aws_ec2_transit_gateway_route_table_association" "main" {
  for_each                       = { for index, cidr in local.vpc_list : index => cidr }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# Add route in your VPC to TGW
resource "aws_route" "to_vpn_clients" {
  for_each               = { for index, cidr in local.vpc_list : index => cidr }

  route_table_id         = module.vpc_private_subnets.route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = var.transit_gateway_id
}

# Allow VPN clients in security group
resource "aws_security_group_rule" "allow_vpn" {
  for_each          = { for index, cidr in local.vpc_list : index => cidr }

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = module.vpc_private_subnets.default_security_group_id
}
