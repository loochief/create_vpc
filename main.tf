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

# Create a VPC
resource "aws_vpc" "First_VPC" {

  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"


  tags = {
    Name = "First VPC"
    Terraform = "true"
    Environment = "Dev"
  }

  enable_dns_hostnames = true
  enable_dns_support = true
}

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

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.First_VPC.id

  tags = {
    Name = "internet_gw"
    Terraform = "true"
    Environment = "Dev"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.First_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public_rt"
    Terraform = "true"
    Environment = "Dev"
  }
}
