provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "web_server" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-0b2bb7a0c7bbe0edb"
  vpc_security_group_ids = ["sg-04567b0352e865522"]
  tags = {
    Name            = "Web Server"
    Deployment_Type = "Terraform"
  }
}