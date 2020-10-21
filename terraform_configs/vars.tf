
variable "vpc_cidr" {
    type = map
    default = {
      prod = "10.100.0.0/16"
      dev = "10.1.0.0/16"
    }
}

############################
# CIDR for public is odd   #
# CIDR for private is even #
############################



variable prod_subnet_list {
   type =  map
    default = {
    public = [ 
      "10.100.5.0/24", 
      "10.100.7.0/24"
    ]

    private = [
       "10.100.6.0/24", 
      "10.100.8.0/24"
    ] }
        
}


variable dev_subnet_list {
   type =  map
    default = {
    public = [ 
      "10.1.1.0/24", 
      "10.1.3.0/24"
    ]

    private = [
       "10.1.2.0/24", 
      "10.1.4.0/24"
    ] }   
}

locals {
  env = terraform.workspace
}

locals {
  subnet_private = local.env == "prod" ? var.prod_subnet_list.private : var.dev_subnet_list.private
  subnet_public = local.env == "prod" ? var.prod_subnet_list.public : var.dev_subnet_list.public
  cidr =  local.env == "prod" ? var.vpc_cidr.prod : var.vpc_cidr.dev 
}



variable "app_port" {
  description = "Docker container port #"
  default     = 5000
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "rajbarath/flask-app:v0.1"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB) = 2GB"
  default     = "2048"
}


variable "region" {
    default = "ca-central-1"
}


variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "alarms_email" {
  description = "Email for CPU high usage in ECS"
  default = "rajbarath@disroot.org"
}

variable "prefix" {
  description = "This is the environment where your webapp is deployed. qa, prod, or dev"
}




