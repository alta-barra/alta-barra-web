data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-vpc-${var.environment}"
  })
}

module "public_subnets" {
  source             = "./subnet"
  vpc_id             = aws_vpc.this.id
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  subnet_type        = "public"
  offset             = 0
  namespace          = var.namespace
  environment        = var.environment
  common_tags        = var.common_tags
}

module "private_subnets" {
  source             = "./subnet"
  vpc_id             = aws_vpc.this.id
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = data.aws_availability_zones.available.names
  subnet_type        = "private"
  offset             = 100
  namespace          = var.namespace
  environment        = var.environment
  common_tags        = var.common_tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-igw-${var.environment}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-public-rt-${var.environment}"
  })
}

resource "aws_route_table_association" "public" {
  for_each = module.public_subnets.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "this" {
  for_each = module.public_subnets.subnet_ids
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.namespace}_EIP_${each.key}_${var.environment}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = module.public_subnets.subnet_ids

  subnet_id     = each.value
  allocation_id = aws_eip.this[each.key].id

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-nat-gw-${each.key}-${var.environment}"
  })
}

resource "aws_route_table" "private" {
  for_each = module.private_subnets.subnet_ids

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-private-rt-${each.key}-${var.environment}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = module.private_subnets.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}

