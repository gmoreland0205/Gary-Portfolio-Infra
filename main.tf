provider "aws" {
  region = var.region
}

#######################################
# Create web server
#######################################

module "nginx_ws" {
  source = "./module/nginx_ws"
  
  project_name = var.project_name
  private_subnet_name = var.private_subnet_name
  instance_type = var.instance_type
} 

#######################################
# Create Resume File Download
#######################################
module "download_resume" {
  source = "./module/download_resume"
  
  project_name = var.project_name
}