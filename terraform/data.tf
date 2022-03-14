data "aws_ami" "AMI" {
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.*-hvm-2.*-x86_64-gp2"]
  }
  filter {
  name = "root-device-type"
  values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners = ["amazon"]
}

data "aws_acm_certificate" "cert-arn" {
  domain = "*.devforfree.tech"
  statuses = ["ISSUED"]
  types = ["AMAZON_ISSUED"]
}

data "aws_instances" "ID" {
  instance_tags = {
    Project = var.project
  }
}
  
  
