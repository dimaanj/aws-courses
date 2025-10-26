# Application Infrastructure - References Network Resources
# This project depends on the network project being deployed first

# Data sources to reference network resources
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

data "aws_vpc" "main" {
  id = data.terraform_remote_state.network.outputs.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_security_group" "elb" {
  id = data.terraform_remote_state.network.outputs.security_group_ids.elb
}

data "aws_security_group" "webserver" {
  id = data.terraform_remote_state.network.outputs.security_group_ids.webserver
}

data "aws_security_group" "tcpserver" {
  id = data.terraform_remote_state.network.outputs.security_group_ids.tcpserver
}

data "aws_security_group" "udpserver" {
  id = data.terraform_remote_state.network.outputs.security_group_ids.udpserver
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

