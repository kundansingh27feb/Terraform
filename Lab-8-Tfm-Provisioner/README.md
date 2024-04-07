# Terraform Provisioners(Local And Remote Exec with aws key file base ssh login): 

Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service. To this point the EC2 web server we have created is useless. We created a server without any running code with no useful services are running on it. We will utilize Terraform provisoners to deploy a webapp onto the instance we’ve created. In order run these steps Terraform needs a connection block along with our generated SSH key from the previous labs in order to authenticate into our instance. Terraform can utilize both the local-exec provisioner to urn commands on our local workstation, and the remote-exec provisoner to install security updates along with our web application. 
#

• Task 1: Upload your SSH keypair to AWS and associate to your instance.  

• Task 2: Create a Security Group that allows SSH to your instance.  

• Task 3: Create a connection block using your SSH keypair.  

• Task 4: Use the local-exec provisioner to change permissions on your local SSH Key  

• Task 5: Create a remote-exec provisioner block to pull down and install web application.  

• Task 6: Apply your configuration and watch for the remote connection.  

• Task 7: Pull up the web application and ssh into the web server (optional)  
#
 

# Task 1: Create an SSH keypair and associate it to your instance. 

In main.tf add the following resource blocks to create a key pair in AWS that is associated with your generated key from the previous lab.  
#
resource "aws_key_pair" "generated" { 

key_name = "MyAWSKey" 

public_key = tls_private_key.generated.public_key_openssh 

lifecycle { 

ignore_changes = [key_name] 

} 

} 
#

# Task 2: Create a Security Group that allows SSH to your instance. 

In main.tf add the following resource block to create a Security Group that allows SSH access.  
#
resource "aws_security_group" "ingress-ssh" { 

name = "allow-all-ssh" 

vpc_id = aws_vpc.vpc.id 

ingress { 

cidr_blocks = [ 

"0.0.0.0/0" 

]

from_port = 22 

to_port = 22 

protocol = "tcp" 

} 

egress { 

from_port = 0 

to_port = 0 

protocol = "-1" 

cidr_blocks = ["0.0.0.0/0"] 

} 

} 
#

In main.tf add the following resource block to create a Security Group that allows web traffic over the standard HTTP and HTTPS ports. 

# Create Security Group - Web Traffic 
#
resource "aws_security_group" "vpc-web" { 

name = "vpc-web-${terraform.workspace}" 

vpc_id = aws_vpc.vpc.id 

description = "Web Traffic" 

ingress { 

description = "Allow Port 80" 

from_port = 80 

to_port = 80 

protocol = "tcp" 

cidr_blocks = ["0.0.0.0/0"] 

} 

ingress { 

description = "Allow Port 443" 
=
from_port = 443 

to_port = 443 

protocol = "tcp" 

cidr_blocks = ["0.0.0.0/0"] 

} 

egress { 

description = "Allow all ip and ports outbound" 

from_port = 0 

to_port = 0 

protocol = "-1" 

cidr_blocks = ["0.0.0.0/0"] 

} 

} 

resource "aws_security_group" "vpc-ping" { 

name = "vpc-ping" 

vpc_id = aws_vpc.vpc.id 

description = "ICMP for Ping Access" 

ingress { 

description = "Allow ICMP Traffic" 

from_port = -1 

to_port = -1 

protocol = "icmp" 

cidr_blocks = ["0.0.0.0/0"] 

} 

egress { 

description = "Allow all ip and ports outboun" 

from_port = 0 

to_port = 0 

protocol = "-1" 

cidr_blocks = ["0.0.0.0/0"] 

} 

} 
#

# Task 3: Create a connection block using your keypair module outputs. 

Replace the aws_instance” “ubuntu_server” resource block in your main.tf with the code below to deploy and Ubuntu server, associate the AWS Key, Security Group and connection block for Terraform to connect to your instance: 
#
resource "aws_instance" "ubuntu_server" { 

ami = data.aws_ami.ubuntu.id 

instance_type = "t2.micro" 

subnet_id = aws_subnet.public_subnets["public_subnet_1 

"].id 

security_groups = [aws_security_group.vpc-ping.id, 

aws_security_group.ingress-ssh.id, aws_security_group.vpc-web.id] 

associate_public_ip_address = true 

key_name = aws_key_pair.generated.key_name 

connection { 

user = "ubuntu" 

private_key = tls_private_key.generated.private_key_pem 

host = self.public_ip 

} 

tags = { 

Name = "Ubuntu EC2 Server" 

} 

lifecycle { 

ignore_changes = [security_groups] 

} 

} 
#

You will notice that we are referencing other resource blocks via Terraform interpolation syntax to associate the security group, keypair and private key for the connection to our instance. The value of self refers to the resource defined by the current block. So self.public_ip refers to the public IP address of our aws_instance.web.  
#
# Task 4: Use the local-exec provisioner to change permissions on your local SSH Key 

The local-exec provisioner invokes a local executable after a resource is created. We will utilize a local-exec provisioner to make sure our private key is permissioned correctly. This invokes a process on the machine running Terraform, not on the resource. Update the aws_instance” “ubuntu_server” resource block in your main.tf to call a local-exec provisioner:  
#
provisioner "local-exec" { 

command = "chmod 600 ${local_file.private_key_pem.filename}" 

} 
#

# Task 5: Create a remote-exec provisioner block to pull down web application 

The remote-exec provisioner runs remote commands on the instance provisoned with Terraform. We can use this provisioner to clone our web application code to the isntance and then invoke the setup script inside aws_instance after local exec. 
#
provisioner "remote-exec" { 

inline = [ 

"sudo rm -rf /tmp", 

"sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",

"sudo sh /tmp/assets/setup-web.sh", 

] 

} 
#

# Task 3: Apply your configuration and watch for the remote connection. 

In order to create our security group, new web ubuntu instance with the associated public SSH Key and execute our provisioners we will validate our code and then initiate a terraform apply. 
#
terraform init 

terraform fmt 

terraform validate 

terraform plan 

terraform apply 
#
 

# Task 7: Pull up the web application and ssh into the web server (optional) 

You can now visit your web application by pointing your browser at the public_ip output for your EC2 instance. To get that address you can look at the state details of the EC2 instance by performing a  
#
terraform state show aws_instance.ubuntu_server  
Find the public IP from the above output and hit on browser 

Visit http://Public_Ip 
#
If you want, you can also ssh to your EC2 instance with a command like ssh -i MyAWSKey.pem ubuntu@Public_IP. Type yes when prompted to use the key. Type exit to quit the ssh session.