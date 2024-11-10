data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_route_table" "aws_default_route_table" {
  vpc_id = data.aws_vpc.default_vpc.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_vpc_peering_connection" "gl_vpc_to_default" {
  vpc_id      = aws_vpc.gl-vpc.id
  peer_vpc_id = data.aws_vpc.default_vpc.id

  auto_accept = true

  tags = merge(
    local.common_tags,
    {
      Name = "gl-vpc-to-default-vpc-peering"
    }
  )
}

resource "aws_route" "gl_vpc_to_default_route" {
  route_table_id            = aws_route_table.public_crt.id
  destination_cidr_block    = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gl_vpc_to_default.id
}

resource "aws_route" "default_vpc_to_gl_vpc" {
  route_table_id            = data.aws_route_table.aws_default_route_table.id
  destination_cidr_block    = aws_vpc.gl-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gl_vpc_to_default.id
}
