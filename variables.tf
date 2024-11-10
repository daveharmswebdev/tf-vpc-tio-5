variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of VPC."
  type        = string
  default     = "gl-vpc"
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ssh_allowed_ip" {
  description = "Allowed ip address for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Amazon Linux 2"
  type        = string
  default     = "ami-0984f4b9e98be44bf"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
