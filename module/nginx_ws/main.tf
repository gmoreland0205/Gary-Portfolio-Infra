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

###############################################
# Create Web Server Security Group and EC2 Instance
###############################################

# Create a security group for the web server
resource "aws_security_group" "nginx_sg" {
  name   = "nginx-webserver-${var.project_name}"
  vpc_id = var.private_subnet_id.vpc_id

  # Allow HTTP traffic from the ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }


  # Allow HTTPS traffic from the ALB security group
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
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
  subnet_id                 = var.private_subnet_id
  vpc_security_group_ids    = [aws_security_group.nginx_sg]
  user_data                 = file("${path.module}/nginx_build_script.sh")

  tags = {
    Name = "nginx-server-${var.project_name}"
  }
}

# Attach the EC2 Web instance to the ALB target group
resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.nginx.id
  port             = 80
}
