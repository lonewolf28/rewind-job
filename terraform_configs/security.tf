#Define security groups that needs to be attached to ALB and ECS cluster

# ALB security group
resource "aws_security_group" "lb" {
  name        = "dev-flask-app-alb-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Limiting traffic to ECS only from ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "dev-flask-app-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

