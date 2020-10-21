# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "flask_log_group" {
  name              = "/ecs/flask-app"
  retention_in_days = 5

  tags = {
    Name = "flask-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "flask_log_stream" {
  name           = "flask-log-stream"
  log_group_name = aws_cloudwatch_log_group.flask_log_group.name
}

