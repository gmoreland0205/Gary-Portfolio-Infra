# Get a AL2023 AMI for the EC2 instance
data "aws_ami" "generic_server" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }
}

data "aws_lb_target_group" "alb_tg" {
  name = "app-servers"
}

data "aws_security_group" "alb_http_sg" {
  name = "alb-http-sg-gary-infra"
}

data "aws_security_group" "alb_https_sg" {
  name = "alb-https-sg-gary-infra"
}

data "aws_security_group" "bastion_sg" {
  name = "terraform-20260520143733140200000005"
}

data "aws_subnet" "private" {
  filter {
    name   = "tag:Name"
    values = [var.private_subnet_name]
  }
}

###############################################
# Create Web Server Security Group and EC2 Instance
###############################################

# Create a security group for the web server
resource "aws_security_group" "nginx_sg" {
  name   = "nginx-webserver-sg-${var.project_name}"
  vpc_id = data.aws_subnet.private.vpc_id

  # Allow HTTP traffic from the ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.aws_security_group.alb_http_sg.id]
  }
  
  # Allow SSH only from Bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion_sg.id]
  }

  # Allow HTTPS traffic from the ALB security group
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [data.aws_security_group.alb_https_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Web instance for the web server
resource "aws_instance" "nginx" {
  ami                       = data.aws_ami.generic_server.id
  instance_type             = var.instance_type
  subnet_id                 = data.aws_subnet.private.id
  key_name                  = "${var.ssh-key-pair}"
  vpc_security_group_ids    = [aws_security_group.nginx_sg.id]
  user_data                 = file("${path.module}/nginx_build_script.sh")

  tags = {
    Name = "nginx-server-${var.project_name}"
  }
}

# Attach the EC2 Web instance to the ALB target group
resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = data.aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}
