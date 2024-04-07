variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_name" {
  type    = string
  default = "demo-vpc"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "private_subnet" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
    "private_subnet_3" = 3
  }
}
variable "public_subnet" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
    "public_subnet_3" = 3
  }
}
variable "variable_sub_cidr" {
  description = "Cird block"
  type        = string
  default     = "10.0.254.0/24"
}
variable "variable_sub_az" {
  description = "Availiblity Zone"
  type        = string
  default     = "us-east-1a"
}
variable "variables_sub_auto_ip" {
  description = "Set Automatic IP"
  type        = string
  default     = "true"
}
variable "environment" {
  description = "server environment"
  type        = string
  default     = "Development"
}