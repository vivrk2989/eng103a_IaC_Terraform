# Terraform init -will download any required pre-requisites




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


resource "aws_subnet" "vivek_tf_subnet1" {
  vpc_id                  = "${aws_vpc.vivek_tf_vpc.id}"
  cidr_block              = "10.0.23.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "eng103a_vivek_tf_subnet"
  }

}

resource "aws_subnet" "vivek_tf_subnet2" {
  vpc_id                  = "${aws_vpc.vivek_tf_vpc.id}"
  cidr_block              = "10.0.25.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1c"
  tags = {
    Name = "eng103a_vivek_tf_subnet2"
  }

}

resource "aws_internet_gateway" "vivek_tf_vpc_ig" {
  vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
  tags = {
    Name = "eng103a_vivek_tf_ig"
  }
}


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
  subnet_id = "${aws_subnet.vivek_tf_subnet1.id}"
  
  key_name = "eng103a_vivek"
# what is the name of your instance
  tags = {
    Name = var.tags
  }
}


# # DEMO VPC

# provider "aws" {
#   region = "eu-west-1"

# }



# resource "aws_vpc" "vivek_tf_vpc" {
#   cidr_block = "10.0.0.0/16"
#   instance_tenancy = "default"


#   tags = {
#      Name = "vivek_vpc_tf"
#   }
  
# }

# resource "aws_internet_gateway" "vivek_tf_vpc_ig" {
#   vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
  
#   tags = {
#     Name = "vivek_vpc_tf_ig"
#   }
# }

# # Creating 1st subnet

# resource "aws_subnet" "public_subnet" {
#   vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
#   cidr_block = "10.0.8.0/24"
#   map_public_ip_on_launch = true
#   availability_zone = "eu-west-1a"

#   tags = {
#      Name = "Public Subnet"

#   }  
  
# }

# # Creating 2nd subnet

# resource "aws_subnet" "public_subnet2" {
#   vpc_id = "${aws_vpc.vivek_tf_vpc.id}"
#   cidr_block = "10.0.9.0/24"
#   map_public_ip_on_launch = true
#   availability_zone = "eu-west-1b"
  
#   tags = {
#      Name = "Subnet 2"
#   }

# }

# # creating Route Table

# resource "aws_route_table" "route" {
#   vpc_id = "${aws_vpc.vivek_tf_vpc.id}"

#   route {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = "${aws_internet_gateway.vivek_tf_vpc_ig.id}"
#   }
#   tags = {
#      Name = "Route to internet"
#   }
# }

# resource "aws_route_table_association" "rtas1" {
#   subnet_id = "${aws_subnet.public_subnet.id}"
#   route_table_id = "${aws_route_table.route.id}"
  
# }

# resource "aws_route_table_association" "rtas2" {
#   subnet_id = "${aws_subnet.public_subnet2.id}"
#   route_table_id = "${aws_route_table.route.id}"
    
# }