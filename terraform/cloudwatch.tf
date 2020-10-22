# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "flask_log_group" {
  name              = "/ecs/flask_app"
  retention_in_days = 5

  tags = {
    Name = "flask_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "flask_log_stream" {
  name           = "flask_log_stream"
  log_group_name = aws_cloudwatch_log_group.flask_log_group.name
}

