resource "aws_cloudwatch_log_group" "example" {
  name              = "/ecs/service"
  retention_in_days = 14
}