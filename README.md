# Infrastructure as code with Terraform
## What is Terraform
### Terraform Architecture
#### Terraform default file/folder structure
##### .gitignore
###### AWS keys with Terraform security
![Image Link](https://github.com/vivrk2989/eng103a_IaC_Terraform/blob/main/Images/Terraform%20architecture.png)

- Terraform commands
- `terraform init` To initialise Terraform
- `terraform plan` checks the script
- `terraform apply` implement the script
- `terraform destroy` to delete everything

- Terraform file/folder structure
- `.tf` extension - `main.tf`
- Apply `DRY`

### Set up AWS keys as an ENV in windows machine
- `AWS_ACCESS_KEY_ID` for was access key
- `AWS_SECRET_KEY` for aws secret
- `click windows key` - `type env` - `edit the system env` 
- click `new` for user variable
- add 2 env variables. Go to windows, and search `env` and then add your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_KEY`
- Creating a new instance with keypair
```
# provider aws 
provider "aws" {
  

# which region
   region = "eu-west-1"
}

# init with terraform `terraform init`
# what do we want to launch
# Automate the process of creating EC2 instance

# name of the resource
resource "aws_instance" "vivek_tf_app" {
  

# which AMI to use
  ami = "ami-07d8796a2b0f8d29c"

# what type of instance
  instance_type = "t2.micro"

# name of the keypair
  key_name = "eng103a_vivek"  

# do you want public IP
  associate_public_ip_address = true

# what is the name of your instance
  tags = {
    Name = "103a_vivek_tf_app"
  }
}
```

### Terraform VPC Task
- Terraform script to create a vpc with public subnet, Internet Gateway, Route Table and an instance with the required security group

- Creating VPC
```
# provider aws 
provider "aws" {


  # which region
  region = "eu-west-1"
}

# init with terraform `terraform init`
# what do we want to launch
# Automate the process of creating EC2 instance



resource "aws_vpc" "vivek_tf_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng103a_vivek_tf_vpc"
  }

}
```
- Subnet
```
resource "aws_subnet" "vivek_tf_subnet" {
  vpc_id                  = "${aws_vpc.vivek_tf_vpc.id}"
  cidr_block              = "10.0.24.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "eng103a_vivek_tf_subnet"
  }

}
```

- Creating Internet Gateway
```
resource "aws_internet_gateway" "vivek_tf_vpc_ig" {
  vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
  tags = {
    Name = "eng103a_vivek_tf_ig"
  }
}

```
- Creating Route table
```
resource "aws_route_table" "vivek_tf_vpc_rt" {
  vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vivek_tf_vpc_ig.id
  }
  tags = {
    Name = "eng103a_vivek_tf_vpc_rt"
  }

}
```

- Assigning security group

```
resource "aws_security_group" "vivek_tf_secgrp" {
  vpc_id = "${aws_vpc.vivek_tf_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "access to the app"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  # ssh access
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  # Allow port 3000 from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "eng103a_vivek_tf_sg_app"
  }
}
```
- Creating Instance within the public subnet
```
# name of the resource
resource "aws_instance" "vivek_tf_app" {


# which AMI to use
  ami = var.app_ami_id

# what type of instance
  instance_type = var.instance_type 

# do you want public IP
  associate_public_ip_address = var.associate_public_ip_address

# specify security group id (if launch on own vpc)
  vpc_security_group_ids = ["${aws_security_group.vivek_tf_secgrp.id}"]

  # specify subnet id (if launch on own vpc)
  subnet_id = "${aws_subnet.vivek_tf_subnet.id}"
  
  key_name = "eng103a_vivek"
# what is the name of your instance
  tags = {
    Name = var.tags
  }
}
```
- Once this is set up, go to aws route table and click `edit subnet associations` and choose the correct one.
- Now we have the app instance running
- Now use the AMI of the Ansible controller to create an instance for the ansible controller. We will be using this to configure the app instance.
- Once set up, ssh into the controller and go to `cd /etc/ansible/` and make changes to the `hosts` file like below
![Image Link](https://github.com/vivrk2989/eng103a_IaC_Terraform/blob/main/Images/ec2%20app%20using%20tf%20and%20ansible.png) 
- Now try to ping this using `sudo ansible app -m ping --ask-vault-pass`
- If you get pong, we are good to go. Now run the playbook scripts already within the controller.
- Copy the app folder, install nginx, install nodejs, install npm and also complete reverse proxy
- ssh into app and then `cd app` and `npm start` to start the app to see the app running in our browser.


