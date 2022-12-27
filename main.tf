terraform {
  required_version = "~> 1.0"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

}

data "aws_availability_zones" "myaz" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ec2_instance_type_offerings" "myinsta" {

  for_each = toset(data.aws_availability_zones.myaz.names)
  filter {
    name   = "instance-type"
    values = ["t2.micro"]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

    location_type = "availability-zone" 
}

resource "aws_instance" "ex" {
  ami           = "ami-0cca134ec43cf708f"
  instance_type = var.instancetype[0]
  user_data     = file("${path.module}/app1-install.sh")
  tags = {
    "Name" = "ec2-demo-${each.key}"
  }
  key_name          = var.sshkey
  for_each          = toset(keys({for az,i in data.aws_ec2_instance_type_offerings.myinsta: az => i.instance_types if length(i.instance_types) !=0}))
  availability_zone = each.value
  # security_groups = [ aws_security_group.mysg.id ]
  vpc_security_group_ids = [aws_security_group.mysg.id]
  #count = 2

}

resource "aws_security_group" "mysg" {
  name = "mysg"


}

resource "aws_security_group_rule" "allowssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.mysg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "-1"
  security_group_id = aws_security_group.mysg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "outbound_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mysg.id
}

resource "local_file" "ansible" {
  content = "example"
  filename = "${path.module}/inventory.txt"
  
}