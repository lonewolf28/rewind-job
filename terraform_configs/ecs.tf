


resource "aws_ecs_cluster" "flask-app" {
  name = "dev-flask-app"
}

data "template_file" "flask-app" {
  template = file("./templates/ecs/flask-app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.region
  }
}

resource "aws_ecs_task_definition" "flask-app" {
  family                   = "flask-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.flask-app.rendered
}

resource "aws_ecs_service" "flask-app" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask-app.id
  task_definition = aws_ecs_task_definition.flask-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.flask-app.id
    container_name   = "dev-flask-app"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

