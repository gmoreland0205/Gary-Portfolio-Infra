variable "project_name" {
    type = string
    default = "garyws-infra"
    description = "Project Name for Website for the web server to be deployed"
}

variable "private_subnet_name" {
    type = string
    description = "Private Subnet Name where the web server will be deployed"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
    description = "EC2 instance type for the web server to be deployed"
}

variable"ssh-key-pair" {
   type = string
   default = "server-key-pair"
   description = "Server Key Pair Name"
}
