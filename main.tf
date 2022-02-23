# Terraform init -will download any required pre-requisites




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

# do you want public IP
  associate_public_ip_address = true

# what is the name of your instance
  tags = {
    Name = "103a_vivek_tf_app"
  }
}

 