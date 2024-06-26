
provider "aws" {
  region = "us-east-1"
}
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = var.vpc_name
    Environment = var.environment
    Created_By  = "Terraform"
    Regin       = data.aws_region.current.name
  }
}
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]

}
# Creating Prvate Subnet
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnet
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 10)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name       = each.key
    Created_By = "Terraform"
  }
}
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnet
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name       = each.key
    Created_By = "Terraform"
  }
}

#Xreating Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Dev_igw"
  }
}

#Creating EIP For Nat Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "Dev_igw_eip"
  }
}
#Creating NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "Dev_nat_gateway"
  }
}

#Creating Route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name       = "dev_public_rtb"
    Created_By = "Terraform"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name       = "dev_privat_rtb"
    Created_By = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}
resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

resource "aws_s3_bucket" "my-bucket-gurukulsiksha" {
  bucket = "my-tfm-bucket-gurukul-${random_id.random_key_for_gurkul.hex}"
  tags = {
    Name       = "Terraform Bucket"
    Created_By = "Terraform"
  }
}
resource "aws_s3_bucket_ownership_controls" "my-gurukulsiksha-bucket-acls" {
  bucket = aws_s3_bucket.my-bucket-gurukulsiksha.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_security_group" "my-gurukulsiksha-security" {
  name        = "gurukulsiksha-security"
  description = "Allow Inbound Traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name       = "Gurukul-Security"
    Created_By = "Terraform"
  }
}
resource "random_id" "random_key_for_gurkul" {
  byte_length = 16
}
resource "aws_subnet" "variable-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.variable_sub_cidr
  availability_zone       = var.variable_sub_az
  map_public_ip_on_launch = var.variables_sub_auto_ip
  tags = {
    Name       = "Variable_subnet"
    Created_By = "Terraform"
  }
}
locals {
  team        = "mgmt_dev"
  application = "corp_mgmt"
  server_name = "gurukul-${var.environment}-${var.variable_sub_az}"
}
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name        = local.server_name
    Owner       = local.team
    Application = local.application
  }
}
module "subnet_addrs" {
  source          = "hashicorp/subnets/cidr"
  version         = "1.0.0"
  base_cidr_block = "10.0.0.0/22"
  networks = [
    {
      name     = "module_network_a"
      new_bits = 2
    },
    {
      name     = "module_network_b"
      new_bits = 2
    },
  ]
}
output "subnet_addrs" {
  value = module.subnet_addrs.network_cidr_blocks
}
