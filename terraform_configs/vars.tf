variable "vpc_dev_cidr" {
    type = string
    default = "10.10.0.0/16"
}


############################
# CIDR for public is odd   #
# CIDR for private is even #
############################


variable "subnet-dev-public" {
    type =  list(string)
    default = [
        "10.10.1.0/24", 
        "10.10.3.0/24"
    ]
}

variable "subnet-dev-private" {
    type =  list(string)
    default = [
        "10.10.2.0/24", 
        "10.10.4.0/24"
    ]
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

