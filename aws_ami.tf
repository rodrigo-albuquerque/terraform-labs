# This file finds the right Ubuntu AMI to install ou our servers.
data "aws_ami" debian {
  most_recent = true

  filter {
    name = "name"
    values = ["debian-10-amd64-20200210-166"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"]
}


