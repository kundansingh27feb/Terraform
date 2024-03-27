#Lab: Terraform Basics
#
#Tasks:
#

#• Task 1: Verify Terraform installation and version

#• Task 2: Initialize Terraform Working Directory: terraform init

#• Task 3: Validating a Configuration: terraform validate

#• Task 4: Genenerating a Terraform Plan: terraform plan

#• Task 5: Applying a Terraform Plan: terraform apply

#• Task 6: Terraform Destroy: terraform destroy

#Hint:

#Create a main.tf file and add below content and run all the basic command for it like

#terraform init

#terraform validate

#terraform fmt

#terraform plan

#terraform plan -out myplan

#terraform apply myplan

#terraform plan -destroy

#terraform destroy

#terraform apply

#terraform destroy
#
main.tf
#
resource "random_string" "random" {

length = 16

}
