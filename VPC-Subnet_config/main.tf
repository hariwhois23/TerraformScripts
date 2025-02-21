#

provider "aws" {
  region = "us-east-1"
  access_key = "<access_key>"
  secret_key = "<secret_key>"
}

resource "aws_vpc" "main-VPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "main-VPC"
    }
}

resource "aws_subnet" "Public"   {
    vpc_id = aws_vpc.main-VPC.id
    cidr_block = "10.0.1.0/28"
    tags = {
        Name = "PublicSub"
    }
}

resource "aws_subnet" "Private"   {
    vpc_id = aws_vpc.main-VPC.id
    
    cidr_block = "10.0.2.0/28"
    tags = {
        Name = "PrivateSub"
    }
}
