# module "cert" {
#     source = "../cert/"
# }


module "networking" {
    source = "../networking/"
}

module "iam" {
    source = "../iam"
}

module "security" {
    source = "../security"
}

module "ecs" {
    source = "../ecs"
}

module "alb" {
    source = "../alb"
}

module "autoscaling" {
    source = "../autoscaling"
}

module "cloudwatch" {
    source = "../cloudwatch"
}