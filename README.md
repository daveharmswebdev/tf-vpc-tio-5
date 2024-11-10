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