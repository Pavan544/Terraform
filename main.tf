#provider

provider "aws" {
  region="us-east-1"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-VPC"
  }
}

resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private"
  }
}

  resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Public"
  }
}
resource "aws_security_group" "tsg" {
  name        = "terraform-sg"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_instance" "web1" {
    ami = "ami-026b57f3c383c2eec"
    instance_type = "t2.micro"
    subnet_id              = aws_subnet.Public.id
    vpc_security_group_ids = [aws_security_group.tsg.id]
    key_name = "tf-keypair"
tags = {
    Name = "Test-server"
  }
}
