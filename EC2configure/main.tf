# Configure the AWS EC2 instance

provider "aws" {
  region = "us-east-1"
  access_key = "<access_key>"
  secret_key = " <secret_key>"
}

resource "aws_instance" "Terraform_created_instance" {
  ami           = "ami-0d9f9dbae7b9a241d"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform_created"
  }
}
