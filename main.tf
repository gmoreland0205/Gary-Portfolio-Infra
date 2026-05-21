provider "aws" {
  region = var.region
}

#######################################
# Create web server
#######################################

module nginx_ws {
  source = "./module/nginx_ws"

  project_name = var.project_name
  private_subnet_id = var.private_subnet_id
  instance_type = var.instance_type
  alb_sg_id = var.alb_sg_id
  alb_target_group_arn = var.alb_target_group_arn
} 

#######################################
# Create Resume File Download
#######################################
module download_resume {
  source = "./module/download_resume"

  project_name = var.project_name
}