# VPC TIO exercise

## VPC
+ Custom
+ Name: gl-vpc
+ CIDR: 10.0.0.0/16
+ Region: us-east-1 (N. Virginia)

## Subnets
+ Attach to vpc created above

#### Public
+ Name: Public
+ Availability Zone: us-east-1a
+ CIDR: 10.0.1.0/24
+ Enable auto-assign public IPv4 address: true

#### Private
+ Name: Private
+ Availability Zone: us-east-1b
+ CIDR: 10.0.2.0/24

## Internet Gateway
+ Name: gl-igw
+ VPC: attached to the vpc above

## Custom Route Table
+ Name: public-crt
+ VPC: attach to the one created above
+ Route: 0.0.0.0/0 
+ Bind to internet gateway
+ Somehow this will have a destination of 10.0.0.0/16 which is the CIDR of the VPC.
+ Subnet: Associate with the public subnet.

## EC2 Instance: Public
+ Name: public-server
+ AMI: Amazon Linux 2.
+ Instance Type: T2 micro.
+ Subnet: Public Subnet
+ Security Group
  + Name: public-server-sg
  + Description: Opens port for SSH and HTTP
  + ssh, private IP
  + http 80
+ User Data: as provided

```bash
#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
IP_ADDR=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4)
echo "ASG instance with IP $IP_ADDR" > /var/www/html/index.html
```

## EC2 Instance: Private
+ Name: private-server
+ AMI: Amazon Linux 2
+ Instance Type: T2 Micro
+ Key Pair: Liftshift
+ VPC: same as above
+ Subnet: Private subnet
+ Security Group
  + Name: private-server-sg
  + Description: opens port for SSH
  + ssh from anywhere

## NAT Gateway
+ Name: gl-nat
+ Subnet: public subnet
+ Needs elastic ip

## Route Table
+ Name: private-crt
+ VPC: see above
+ Destination: 0.0.0.0/0
+ Target: NAT Gateway
+ Subnet Association: private

## Peering connection
+ Name: gl-vpc-peer
+ Select a local peer: default
+ Other vpc: gl-vpc

## Clean Up

```bash
❯ terraform destroy
data.aws_vpc.default_vpc: Reading...
aws_vpc.gl-vpc: Refreshing state... [id=vpc-0ea162396bbd10d1c]
aws_eip.gl_nat_eip: Refreshing state... [id=eipalloc-00bb01a8bd56ee7c8]
data.aws_vpc.default_vpc: Read complete after 0s [id=vpc-0cada06644d5167a9]
data.aws_route_table.aws_default_route_table: Reading...
data.aws_route_table.aws_default_route_table: Read complete after 0s [id=rtb-0479b8004ec7d75fd]
aws_vpc_peering_connection.gl_vpc_to_default: Refreshing state... [id=pcx-05cd8c8de27ab3e87]
aws_internet_gateway.gl_igw: Refreshing state... [id=igw-032afdd97fb478e07]
aws_subnet.private_subnet: Refreshing state... [id=subnet-07e678c83edd8a510]
aws_subnet.public_subnet: Refreshing state... [id=subnet-0b444251c40c66ad6]
aws_security_group.public_server_sg: Refreshing state... [id=sg-09384724913c4ee66]
aws_route.default_vpc_to_gl_vpc: Refreshing state... [id=r-rtb-0479b8004ec7d75fd179966490]
aws_route_table.public_crt: Refreshing state... [id=rtb-09c79f317f962c07e]
aws_nat_gateway.gl_nat_gw: Refreshing state... [id=nat-0c8fcc9b20797cef4]
aws_route_table_association.public_association: Refreshing state... [id=rtbassoc-02b15f23e29be4fb7]
aws_route.gl_vpc_to_default_route: Refreshing state... [id=r-rtb-09c79f317f962c07e3854007479]
aws_instance.public_server: Refreshing state... [id=i-03754ac737e5a2223]
aws_route_table.private_crt: Refreshing state... [id=rtb-02fb9790fb13474d1]
aws_route_table_association.private_association: Refreshing state... [id=rtbassoc-09a98e4a76c09278f]
aws_security_group.private_server_sg: Refreshing state... [id=sg-09612f89157a61072]
aws_instance.private_server: Refreshing state... [id=i-023740439a201604e]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_eip.gl_nat_eip will be destroyed
  - resource "aws_eip" "gl_nat_eip" {
      - allocation_id            = "eipalloc-00bb01a8bd56ee7c8" -> null
      - arn                      = "arn:aws:ec2:us-east-1:417355468534:elastic-ip/eipalloc-00bb01a8bd56ee7c8" -> null
      - association_id           = "eipassoc-03588423e3be451c4" -> null
      - domain                   = "vpc" -> null
      - id                       = "eipalloc-00bb01a8bd56ee7c8" -> null
      - network_border_group     = "us-east-1" -> null
      - network_interface        = "eni-07b4ea08524aa09fb" -> null
      - private_dns              = "ip-10-0-1-185.ec2.internal" -> null
      - private_ip               = "10.0.1.185" -> null
      - public_dns               = "ec2-54-227-225-74.compute-1.amazonaws.com" -> null
      - public_ip                = "54.227.225.74" -> null
      - public_ipv4_pool         = "amazon" -> null
      - tags                     = {} -> null
      - tags_all                 = {} -> null
      - vpc                      = true -> null
        # (5 unchanged attributes hidden)
    }

  # aws_instance.private_server will be destroyed
  - resource "aws_instance" "private_server" {
      - ami                                  = "ami-0984f4b9e98be44bf" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:417355468534:instance/i-023740439a201604e" -> null
      - associate_public_ip_address          = false -> null
      - availability_zone                    = "us-east-1b" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-023740439a201604e" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "liftshift" -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-055b5b6c828152b54" -> null
      - private_dns                          = "ip-10-0-2-165.ec2.internal" -> null
      - private_ip                           = "10.0.2.165" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-07e678c83edd8a510" -> null
      - tags                                 = {
          - "Name"      = "private_server"
          - "Terraform" = "true"
        } -> null
      - tags_all                             = {
          - "Name"      = "private_server"
          - "Terraform" = "true"
        } -> null
      - tenancy                              = "default" -> null
      - user_data_replace_on_change          = false -> null
      - vpc_security_group_ids               = [
          - "sg-09612f89157a61072",
        ] -> null
        # (9 unchanged attributes hidden)

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - cpu_options {
          - core_count       = 1 -> null
          - threads_per_core = 1 -> null
            # (1 unchanged attribute hidden)
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - maintenance_options {
          - auto_recovery = "default" -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - private_dns_name_options {
          - enable_resource_name_dns_a_record    = false -> null
          - enable_resource_name_dns_aaaa_record = false -> null
          - hostname_type                        = "ip-name" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-04e9aa7b5821b7d64" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
            # (1 unchanged attribute hidden)
        }
    }

  # aws_instance.public_server will be destroyed
  - resource "aws_instance" "public_server" {
      - ami                                  = "ami-0984f4b9e98be44bf" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:417355468534:instance/i-03754ac737e5a2223" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1a" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-03754ac737e5a2223" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "liftshift" -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-0258f42dba537ef8e" -> null
      - private_dns                          = "ip-10-0-1-242.ec2.internal" -> null
      - private_ip                           = "10.0.1.242" -> null
      - public_ip                            = "54.87.229.84" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-0b444251c40c66ad6" -> null
      - tags                                 = {
          - "Name"      = "public-server"
          - "Terraform" = "true"
        } -> null
      - tags_all                             = {
          - "Name"      = "public-server"
          - "Terraform" = "true"
        } -> null
      - tenancy                              = "default" -> null
      - user_data                            = "10c93c347900c6be6f432c74d53e93c1c989c9e4" -> null
      - user_data_replace_on_change          = false -> null
      - vpc_security_group_ids               = [
          - "sg-09384724913c4ee66",
        ] -> null
        # (8 unchanged attributes hidden)

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - cpu_options {
          - core_count       = 1 -> null
          - threads_per_core = 1 -> null
            # (1 unchanged attribute hidden)
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - maintenance_options {
          - auto_recovery = "default" -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - private_dns_name_options {
          - enable_resource_name_dns_a_record    = false -> null
          - enable_resource_name_dns_aaaa_record = false -> null
          - hostname_type                        = "ip-name" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-072682454fa7ed449" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
            # (1 unchanged attribute hidden)
        }
    }

  # aws_internet_gateway.gl_igw will be destroyed
  - resource "aws_internet_gateway" "gl_igw" {
      - arn      = "arn:aws:ec2:us-east-1:417355468534:internet-gateway/igw-032afdd97fb478e07" -> null
      - id       = "igw-032afdd97fb478e07" -> null
      - owner_id = "417355468534" -> null
      - tags     = {
          - "Name"      = "gl_igw"
          - "Terraform" = "true"
        } -> null
      - tags_all = {
          - "Name"      = "gl_igw"
          - "Terraform" = "true"
        } -> null
      - vpc_id   = "vpc-0ea162396bbd10d1c" -> null
    }

  # aws_nat_gateway.gl_nat_gw will be destroyed
  - resource "aws_nat_gateway" "gl_nat_gw" {
      - allocation_id                      = "eipalloc-00bb01a8bd56ee7c8" -> null
      - association_id                     = "eipassoc-03588423e3be451c4" -> null
      - connectivity_type                  = "public" -> null
      - id                                 = "nat-0c8fcc9b20797cef4" -> null
      - network_interface_id               = "eni-07b4ea08524aa09fb" -> null
      - private_ip                         = "10.0.1.185" -> null
      - public_ip                          = "54.227.225.74" -> null
      - secondary_allocation_ids           = [] -> null
      - secondary_private_ip_address_count = 0 -> null
      - secondary_private_ip_addresses     = [] -> null
      - subnet_id                          = "subnet-0b444251c40c66ad6" -> null
      - tags                               = {
          - "Name"      = "gl-nat"
          - "Terraform" = "true"
        } -> null
      - tags_all                           = {
          - "Name"      = "gl-nat"
          - "Terraform" = "true"
        } -> null
    }

  # aws_route.default_vpc_to_gl_vpc will be destroyed
  - resource "aws_route" "default_vpc_to_gl_vpc" {
      - destination_cidr_block      = "10.0.0.0/16" -> null
      - id                          = "r-rtb-0479b8004ec7d75fd179966490" -> null
      - origin                      = "CreateRoute" -> null
      - route_table_id              = "rtb-0479b8004ec7d75fd" -> null
      - state                       = "active" -> null
      - vpc_peering_connection_id   = "pcx-05cd8c8de27ab3e87" -> null
        # (13 unchanged attributes hidden)
    }

  # aws_route.gl_vpc_to_default_route will be destroyed
  - resource "aws_route" "gl_vpc_to_default_route" {
      - destination_cidr_block      = "172.31.0.0/16" -> null
      - id                          = "r-rtb-09c79f317f962c07e3854007479" -> null
      - origin                      = "CreateRoute" -> null
      - route_table_id              = "rtb-09c79f317f962c07e" -> null
      - state                       = "active" -> null
      - vpc_peering_connection_id   = "pcx-05cd8c8de27ab3e87" -> null
        # (13 unchanged attributes hidden)
    }

  # aws_route_table.private_crt will be destroyed
  - resource "aws_route_table" "private_crt" {
      - arn              = "arn:aws:ec2:us-east-1:417355468534:route-table/rtb-02fb9790fb13474d1" -> null
      - id               = "rtb-02fb9790fb13474d1" -> null
      - owner_id         = "417355468534" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - nat_gateway_id             = "nat-0c8fcc9b20797cef4"
                # (11 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "Name"      = "private_crt"
          - "Terraform" = "true"
        } -> null
      - tags_all         = {
          - "Name"      = "private_crt"
          - "Terraform" = "true"
        } -> null
      - vpc_id           = "vpc-0ea162396bbd10d1c" -> null
    }

  # aws_route_table.public_crt will be destroyed
  - resource "aws_route_table" "public_crt" {
      - arn              = "arn:aws:ec2:us-east-1:417355468534:route-table/rtb-09c79f317f962c07e" -> null
      - id               = "rtb-09c79f317f962c07e" -> null
      - owner_id         = "417355468534" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-032afdd97fb478e07"
                # (11 unchanged attributes hidden)
            },
          - {
              - cidr_block                 = "172.31.0.0/16"
              - vpc_peering_connection_id  = "pcx-05cd8c8de27ab3e87"
                # (11 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "Name"      = "public-crt"
          - "Terraform" = "true"
        } -> null
      - tags_all         = {
          - "Name"      = "public-crt"
          - "Terraform" = "true"
        } -> null
      - vpc_id           = "vpc-0ea162396bbd10d1c" -> null
    }

  # aws_route_table_association.private_association will be destroyed
  - resource "aws_route_table_association" "private_association" {
      - id             = "rtbassoc-09a98e4a76c09278f" -> null
      - route_table_id = "rtb-02fb9790fb13474d1" -> null
      - subnet_id      = "subnet-07e678c83edd8a510" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_route_table_association.public_association will be destroyed
  - resource "aws_route_table_association" "public_association" {
      - id             = "rtbassoc-02b15f23e29be4fb7" -> null
      - route_table_id = "rtb-09c79f317f962c07e" -> null
      - subnet_id      = "subnet-0b444251c40c66ad6" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.private_server_sg will be destroyed
  - resource "aws_security_group" "private_server_sg" {
      - arn                    = "arn:aws:ec2:us-east-1:417355468534:security-group/sg-09612f89157a61072" -> null
      - description            = "Opens port for SSH" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ] -> null
      - id                     = "sg-09612f89157a61072" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "10.0.1.242/32",
                ]
              - description      = "SSH"
              - from_port        = 22
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "terraform-20241110214507024400000001" -> null
      - name_prefix            = "terraform-" -> null
      - owner_id               = "417355468534" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name"      = "private-server-SG"
          - "Terraform" = "true"
        } -> null
      - tags_all               = {
          - "Name"      = "private-server-SG"
          - "Terraform" = "true"
        } -> null
      - vpc_id                 = "vpc-0ea162396bbd10d1c" -> null
    }

  # aws_security_group.public_server_sg will be destroyed
  - resource "aws_security_group" "public_server_sg" {
      - arn                    = "arn:aws:ec2:us-east-1:417355468534:security-group/sg-09384724913c4ee66" -> null
      - description            = "Opens port for SSH and HTTP" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ] -> null
      - id                     = "sg-09384724913c4ee66" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "HTTP"
              - from_port        = 80
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 80
            },
          - {
              - cidr_blocks      = [
                  - "69.226.237.216/32",
                ]
              - description      = "SSH"
              - from_port        = 22
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "terraform-20241110204009651800000001" -> null
      - name_prefix            = "terraform-" -> null
      - owner_id               = "417355468534" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name"      = "public-server-SG"
          - "Terraform" = "true"
        } -> null
      - tags_all               = {
          - "Name"      = "public-server-SG"
          - "Terraform" = "true"
        } -> null
      - vpc_id                 = "vpc-0ea162396bbd10d1c" -> null
    }

  # aws_subnet.private_subnet will be destroyed
  - resource "aws_subnet" "private_subnet" {
      - arn                                            = "arn:aws:ec2:us-east-1:417355468534:subnet/subnet-07e678c83edd8a510" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1b" -> null
      - availability_zone_id                           = "use1-az6" -> null
      - cidr_block                                     = "10.0.2.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-07e678c83edd8a510" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "417355468534" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"      = "private_subnet"
          - "Terraform" = "true"
        } -> null
      - tags_all                                       = {
          - "Name"      = "private_subnet"
          - "Terraform" = "true"
        } -> null
      - vpc_id                                         = "vpc-0ea162396bbd10d1c" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_subnet.public_subnet will be destroyed
  - resource "aws_subnet" "public_subnet" {
      - arn                                            = "arn:aws:ec2:us-east-1:417355468534:subnet/subnet-0b444251c40c66ad6" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az4" -> null
      - cidr_block                                     = "10.0.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0b444251c40c66ad6" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "417355468534" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"      = "public_subnet"
          - "Terraform" = "true"
        } -> null
      - tags_all                                       = {
          - "Name"      = "public_subnet"
          - "Terraform" = "true"
        } -> null
      - vpc_id                                         = "vpc-0ea162396bbd10d1c" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.gl-vpc will be destroyed
  - resource "aws_vpc" "gl-vpc" {
      - arn                                  = "arn:aws:ec2:us-east-1:417355468534:vpc/vpc-0ea162396bbd10d1c" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-0c2ec6380808281e6" -> null
      - default_route_table_id               = "rtb-0b20f9ca823e4d4d6" -> null
      - default_security_group_id            = "sg-00f89e7f4f231fa9b" -> null
      - dhcp_options_id                      = "dopt-0fa9841baa3505eeb" -> null
      - enable_dns_hostnames                 = false -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0ea162396bbd10d1c" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0b20f9ca823e4d4d6" -> null
      - owner_id                             = "417355468534" -> null
      - tags                                 = {
          - "Name"      = "gl-vpc"
          - "Terraform" = "true"
        } -> null
      - tags_all                             = {
          - "Name"      = "gl-vpc"
          - "Terraform" = "true"
        } -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc_peering_connection.gl_vpc_to_default will be destroyed
  - resource "aws_vpc_peering_connection" "gl_vpc_to_default" {
      - accept_status = "active" -> null
      - auto_accept   = true -> null
      - id            = "pcx-05cd8c8de27ab3e87" -> null
      - peer_owner_id = "417355468534" -> null
      - peer_region   = "us-east-1" -> null
      - peer_vpc_id   = "vpc-0cada06644d5167a9" -> null
      - tags          = {
          - "Name"      = "gl-vpc-to-default-vpc-peering"
          - "Terraform" = "true"
        } -> null
      - tags_all      = {
          - "Name"      = "gl-vpc-to-default-vpc-peering"
          - "Terraform" = "true"
        } -> null
      - vpc_id        = "vpc-0ea162396bbd10d1c" -> null

      - accepter {
          - allow_remote_vpc_dns_resolution = false -> null
        }

      - requester {
          - allow_remote_vpc_dns_resolution = false -> null
        }
    }

Plan: 0 to add, 0 to change, 17 to destroy.

Changes to Outputs:
  - internet_gateway_id       = "igw-032afdd97fb478e07" -> null
  - nat_gateway_id            = "nat-0c8fcc9b20797cef4" -> null
  - private_route_table_id    = "rtb-02fb9790fb13474d1" -> null
  - private_server_ec2        = "i-023740439a201604e" -> null
  - private_server_sg_id      = "sg-09612f89157a61072" -> null
  - private_subnet_cidr_block = "10.0.2.0/24" -> null
  - private_subnet_id         = "subnet-07e678c83edd8a510" -> null
  - public_route_table_id     = "rtb-09c79f317f962c07e" -> null
  - public_server_ec2         = "i-03754ac737e5a2223" -> null
  - public_server_sg_id       = "sg-09384724913c4ee66" -> null
  - public_subnet_cidr_block  = "10.0.1.0/24" -> null
  - public_subnet_id          = "subnet-0b444251c40c66ad6" -> null
  - vpc_cidr_block            = "10.0.0.0/16" -> null
  - vpc_id                    = "vpc-0ea162396bbd10d1c" -> null
  - vpc_peering_connection_id = "pcx-05cd8c8de27ab3e87" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
  
aws_route_table_association.private_association: Destroying... [id=rtbassoc-09a98e4a76c09278f]
aws_route_table_association.public_association: Destroying... [id=rtbassoc-02b15f23e29be4fb7]
aws_route.gl_vpc_to_default_route: Destroying... [id=r-rtb-09c79f317f962c07e3854007479]
aws_route.default_vpc_to_gl_vpc: Destroying... [id=r-rtb-0479b8004ec7d75fd179966490]
aws_instance.private_server: Destroying... [id=i-023740439a201604e]
aws_route_table_association.private_association: Destruction complete after 1s
aws_route_table_association.public_association: Destruction complete after 1s
aws_route_table.private_crt: Destroying... [id=rtb-02fb9790fb13474d1]
aws_route.gl_vpc_to_default_route: Destruction complete after 1s
aws_route_table.public_crt: Destroying... [id=rtb-09c79f317f962c07e]
aws_route.default_vpc_to_gl_vpc: Destruction complete after 1s
aws_vpc_peering_connection.gl_vpc_to_default: Destroying... [id=pcx-05cd8c8de27ab3e87]
aws_vpc_peering_connection.gl_vpc_to_default: Destruction complete after 0s
aws_route_table.private_crt: Destruction complete after 0s
aws_nat_gateway.gl_nat_gw: Destroying... [id=nat-0c8fcc9b20797cef4]
aws_route_table.public_crt: Destruction complete after 1s
aws_internet_gateway.gl_igw: Destroying... [id=igw-032afdd97fb478e07]
aws_instance.private_server: Still destroying... [id=i-023740439a201604e, 10s elapsed]
aws_nat_gateway.gl_nat_gw: Still destroying... [id=nat-0c8fcc9b20797cef4, 10s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 10s elapsed]
aws_instance.private_server: Still destroying... [id=i-023740439a201604e, 20s elapsed]
aws_nat_gateway.gl_nat_gw: Still destroying... [id=nat-0c8fcc9b20797cef4, 20s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 20s elapsed]
aws_instance.private_server: Still destroying... [id=i-023740439a201604e, 30s elapsed]
aws_nat_gateway.gl_nat_gw: Still destroying... [id=nat-0c8fcc9b20797cef4, 30s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 30s elapsed]
aws_instance.private_server: Still destroying... [id=i-023740439a201604e, 40s elapsed]
aws_instance.private_server: Destruction complete after 41s
aws_subnet.private_subnet: Destroying... [id=subnet-07e678c83edd8a510]
aws_security_group.private_server_sg: Destroying... [id=sg-09612f89157a61072]
aws_nat_gateway.gl_nat_gw: Still destroying... [id=nat-0c8fcc9b20797cef4, 40s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 40s elapsed]
aws_subnet.private_subnet: Destruction complete after 1s
aws_nat_gateway.gl_nat_gw: Destruction complete after 41s
aws_eip.gl_nat_eip: Destroying... [id=eipalloc-00bb01a8bd56ee7c8]
aws_security_group.private_server_sg: Destruction complete after 1s
aws_instance.public_server: Destroying... [id=i-03754ac737e5a2223]
aws_eip.gl_nat_eip: Destruction complete after 1s
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 50s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 10s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 1m0s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 20s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 1m10s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 30s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 1m20s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 40s elapsed]
aws_internet_gateway.gl_igw: Still destroying... [id=igw-032afdd97fb478e07, 1m30s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 50s elapsed]
aws_internet_gateway.gl_igw: Destruction complete after 1m38s
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 1m0s elapsed]
aws_instance.public_server: Still destroying... [id=i-03754ac737e5a2223, 1m10s elapsed]
aws_instance.public_server: Destruction complete after 1m11s
aws_subnet.public_subnet: Destroying... [id=subnet-0b444251c40c66ad6]
aws_security_group.public_server_sg: Destroying... [id=sg-09384724913c4ee66]
aws_subnet.public_subnet: Destruction complete after 0s
aws_security_group.public_server_sg: Destruction complete after 1s
aws_vpc.gl-vpc: Destroying... [id=vpc-0ea162396bbd10d1c]
aws_vpc.gl-vpc: Destruction complete after 0s

Destroy complete! Resources: 17 destroyed.
```
