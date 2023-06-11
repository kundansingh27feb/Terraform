provider "aws" {
  region = "us-west-2" 
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  
  availability_zone = "us-west-2a"
  tags = {
    Name = "MySubnet"
  }
}