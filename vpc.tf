provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Terraform = "true"
  }
}

resource "aws_vpc" "gl-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(
    local.common_tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.gl-vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "public_subnet"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gl-vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = "us-east-1b"

  tags = merge(
    local.common_tags,
    {
      Name = "private_subnet"
    }
  )
}