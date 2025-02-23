provider "aws" {
  region = "us-east-1"
  access_key = "<>key"
  secret_key = "<key>"
}

# Creating a VPC
resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-VPC"
  }
}

# Attaching an Internet Gateway (IGW) to the VPC
resource "aws_internet_gateway" "mainvpc_IGW" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "Igw-prod-vpc"
  }
}

# Creating a Route Table
resource "aws_route_table" "prod_RT" {
  vpc_id = aws_vpc.mainvpc.id  # Fixed incorrect reference

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mainvpc_IGW.id
  }

  tags = {
    Name = "Prod-RTB"
  }
}

# Creating a Subnet in the VPC
resource "aws_subnet" "prod_subnet" {
  vpc_id            = aws_vpc.mainvpc.id  # Fixed incorrect reference
  cidr_block        = "10.0.1.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-1-Sb"
  }
}

# Associating the Route Table with the Subnet
resource "aws_route_table_association" "RTB_asso" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_RT.id  # Fixed incorrect reference
}

# Creating a Security Group
resource "aws_security_group" "sg_traffic" {
  name        = "SG-traffic"
  description = "Allow SSH (22), HTTP (80), and HTTPS (443) inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.mainvpc.id

  tags = {
    Name = "SG-traffic"
  }
}

# Ingress Rule (Allow SSH on Port 22)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg_traffic.id
  cidr_ipv4         = "0.0.0.0/0"  # Allow SSH from anywhere (⚠️ Restrict this for better security)
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Ingress Rule (Allow HTTP on Port 80)
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg_traffic.id
  cidr_ipv4         = "0.0.0.0/0"  # Allow HTTP from anywhere
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Ingress Rule (Allow HTTPS on Port 443)
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.sg_traffic.id
  cidr_ipv4         = "0.0.0.0/0"  # Allow HTTPS from anywhere
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Egress Rule (Allow All Outbound Traffic)
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.sg_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  
  ip_protocol       = "-1"  # Allows all protocols
  
}

# Creating a Network Interface
resource "aws_network_interface" "nif_aws" {
  subnet_id       = aws_subnet.prod_subnet.id
  private_ips     = ["10.0.1.4"]
  security_groups = [aws_security_group.sg_traffic.id]  # Fixed incorrect reference

  tags = {
    Name = "prod-nic"
  }
}

# Creating an Elastic IP
resource "aws_eip" "one" {
  domain                  = "vpc"
  network_interface       = aws_network_interface.nif_aws.id
  associate_with_private_ip = "10.0.1.4"

  depends_on = [aws_internet_gateway.mainvpc_IGW]
}

# Creating an Ubuntu Server Instance
resource "aws_instance" "server" {
  ami               = "ami-0d9f9dbae7b9a241d"  # Ubuntu AMI
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "Terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nif_aws.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo "Your first server" > /var/www/html/index.html'
  EOF

  tags = {
    Name = "Web-server"
  }
}
