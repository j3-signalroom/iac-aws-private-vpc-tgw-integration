resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.vpc_name}-${var.environment_name}-vpc"
    Environment = var.environment_name
  }
}

resource "aws_subnet" "private" {
  count = local.subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index)
  availability_zone = local.azs[count.index]

  tags = {
    Name        = "${var.vpc_name}-${var.environment_name}-private-subnet-${count.index + 1}"
    Environment = var.environment_name
    AZ          = local.azs[count.index]
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.vpc_name}-${var.environment_name}-private-rt"
    Environment = var.environment_name
  }
}

resource "aws_route_table_association" "private" {
  count = local.subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}