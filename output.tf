output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.gl-vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.gl-vpc.cidr_block
}

output "public_subnet_cidr_block" {
  description = "The CIDR block of the public subnet"
  value       = aws_subnet.public_subnet.cidr_block
}

output "private_subnet_cidr_block" {
  description = "The CIDR block of the private subnet"
  value       = aws_subnet.private_subnet.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.gl_igw.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_crt.id
}

output "public_server_sg_id" {
  description = "The ID of the public server security group"
  value       = aws_security_group.public_server_sg.id
}

output "public_server_ec2" {
  description = "The ID of the public EC2 instance"
  value       = aws_instance.public_server.id
}

output "private_server_sg_id" {
  description = "The ID of the private server security group"
  value       = aws_security_group.private_server_sg.id
}

output "private_server_ec2" {
  description = "The ID of the private EC2 instance"
  value       = aws_instance.private_server.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.gl_nat_gw.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private_crt.id
}
