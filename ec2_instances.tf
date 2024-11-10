resource "aws_instance" "public_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")
  key_name                    = var.key_pair

  vpc_security_group_ids = [aws_security_group.public_server_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "public-server"
    }
  )
}

resource "aws_instance" "private_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = var.key_pair

  vpc_security_group_ids = [aws_security_group.private_server_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "private_server"
    }
  )
}