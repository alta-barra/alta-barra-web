variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the subnet will be created"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "subnet_type" {
  type        = string
  description = "Type of the subnet: public or private"
}

variable "offset" {
  type        = number
  description = "CIDR block offset to avoid conflicts"
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

resource "aws_subnet" "this" {
  for_each = { for i, az in var.availability_zones : az => i }

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, var.offset + each.value)
  availability_zone = each.key

  tags = merge(var.common_tags, {
    Name = "${var.namespace}-${var.subnet_type}-subnet-${each.key}-${var.environment}"
  })
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.this : subnet.id]
}
