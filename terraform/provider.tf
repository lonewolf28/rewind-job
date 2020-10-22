provider "aws" {
  version = "~> 3.0"
  region  = "ca-central-1"

}


terraform {
  backend "s3" {
    bucket = "rewind-terraform-backend"
    key    = "ecs-cluster-app/terraform.tfstate"
    region = "ca-central-1"
    encrypt        = true
  }
}
