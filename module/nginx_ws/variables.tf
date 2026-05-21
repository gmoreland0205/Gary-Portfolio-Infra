variable "project_name" {
    type = string
    default = "garyws-infra"
    description = "Project Name for Website for the web server to be deployed"
}

variable "private_subnet_id" {
    type = string
    description = "Private Subnet ID where the web server will be deployed"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
    description = "EC2 instance type for the web server to be deployed"
}

variable "alb_sg_id" {
    type = string
    description = "Security Group ID of the Application Load Balancer to allow traffic from"
}

variable "alb_target_group_arn" {
    type = string
    description = "Application Load Balancer Target Group ARN to be attached"
}
