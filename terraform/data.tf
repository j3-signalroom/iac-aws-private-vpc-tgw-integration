locals {
  vpc_list   = tolist(toset(split(",", var.vpc_cidrs)))
  vpc_prefix = tonumber(split("/", local.vpc_list[0])[1])
  newbits    = var.subnet_prefix - local.vpc_prefix
}