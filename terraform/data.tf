data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_count = var.subnet_count
  azs          = slice(data.aws_availability_zones.available.names, 0, local.subnet_count)
}