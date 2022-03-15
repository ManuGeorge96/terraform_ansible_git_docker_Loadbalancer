resource "aws_vpc" "VPC" {
 cidr_block = var.cidr
 enable_dns_hostnames = true
 tags = {
    Name = "${var.project}-VPC"
    Project = var.project
 }
}

locals{
  subnet = floor(log((length(var.AZ)) *2,2))
}

resource "aws_subnet" "subnet" {
  availability_zone = element(var.AZ, count.index)
  cidr_block = cidrsubnet( var.cidr, local.subnet, "${count.index}")
  count = length(var.AZ)
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${var.project}-Sub-net-${count.index + 1}"
    Project = var.project
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${var.project}-IGW"
    Project = var.project
  }
}

resource "aws_route_table" "RTB" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "${var.project}-RTB"
    Project = var.project
  }
}

resource "aws_route_table_association" "associate" {
  count = length(var.AZ)
  subnet_id = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = aws_route_table.RTB.id
}

resource "aws_security_group" "SG" {
  name = "${var.project}-SG"
  vpc_id =  aws_vpc.VPC.id
  egress {
    protocol = "-1"
    from_port = "0"
    to_port = "0"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = {
    Name = "${var.project}-SG"
    Project = var.project
  }
}
  
resource "aws_security_group_rule" "rules" {
  for_each = toset(var.port)
  type = "ingress"
  security_group_id = aws_security_group.SG.id
  protocol = "tcp"
  from_port = each.value
  to_port = each.value
  cidr_blocks = [ "0.0.0.0/0" ]
  ipv6_cidr_blocks = [ "::/0" ]
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.AMI.id
  count = length(aws_subnet.subnet.*.id)
  subnet_id = element(aws_subnet.subnet.*.id, count.index)
  instance_type = "t2.micro"
  key_name = "Recovery_Instance"
  vpc_security_group_ids = [aws_security_group.SG.id]
  tags = {
    Name = "${var.project}-EC2-${count.index + 1}"
    Project = var.project
  }
}

resource "aws_lb" "Load-Balancer" {
  name = "${var.project}-ALB"
  load_balancer_type = "application"
  security_groups = [aws_security_group.SG.id]
  subnets = [ for subnet in aws_subnet.subnet : subnet.id ]
  tags = {
    Name = "${var.project}-ALB"
    Project = var.project
  }
}

resource "aws_lb_target_group" "Tgroup" {
  deregistration_delay = "2"
  name = "${var.project}-ALB"
  port = "80"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.VPC.id
  health_check {
    timeout = "3"
    interval = "5"
    healthy_threshold = "2"
    unhealthy_threshold = "2"
    port = "80"
    protocol = "HTTP"
  }
  tags = {
    Name = "${var.project}-TagetGroup"  
    Project = var.project
  }
}

resource "aws_lb_target_group_attachment" "targets" {
  target_group_arn = aws_lb_target_group.Tgroup.arn
  target_id = element(aws_instance.ec2.*.id, count.index)
  count = length(aws_instance.ec2.*.id)
  depends_on = [aws_instance.ec2]
}

resource "aws_lb_listener" "Listener1" {
  load_balancer_arn = aws_lb.Load-Balancer.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}    

resource "aws_lb_listener" "Listener" {
  load_balancer_arn = aws_lb.Load-Balancer.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.cert-arn.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = "500"
    }
  }
  tags = {
    Name = "${var.project}-Listener"
    Project = var.project
  }
}

resource "aws_lb_listener_rule" "Rule" {
  listener_arn = aws_lb_listener.Listener.arn  
  priority = "1"
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Tgroup.arn
  }
  condition {
    host_header {
      values = ["ansible.devforfree.tech"]
    }
  }
  tags = {
    Name = "${var.project}-Listener"
    Project = var.project
  }
}
