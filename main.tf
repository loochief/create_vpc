terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Section Create a VPC
resource "aws_vpc" "First_VPC" {

  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"


  tags = {
    Name = "Dev VPC"
    Terraform = "true"
    Environment = "Dev"
  }

  enable_dns_hostnames = true
  enable_dns_support = true
}

#Section creates a public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.First_VPC.id
  cidr_block = "192.168.1.0/24"
  availability_zone_id = "use1-az1"

  tags = {
    Name = "public_subnet"
    Terraform = "true"
    Environment = "Dev"
  }
}

#Section Creates an Internet Gateay in the public subnet
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.First_VPC.id

  tags = {
    Name = "internet_gw"
    Terraform = "true"
    Environment = "Dev"
  }
}
#Section Creates a NAT Gateway in the public subnet
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT gw"
  }
  depends_on = [aws_internet_gateway.internet_gw, aws_eip.nat_gateway_eip]
  
}

#Section creates a private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.First_VPC.id
  cidr_block = "192.168.4.0/24"
  availability_zone_id = "use1-az1"

  tags = {
    Name = "private_subnet"
    Terraform = "true"
    Environment = "Dev"
  }
}

#Section creates a public route table with a default route to Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.First_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "public_rt"
    Terraform = "true"
    Environment = "Dev"
  }
}

#Section creates a private route table with a default route to the NAT gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.First_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private_rt"
    Terraform = "true"
    Environment = "Dev"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}