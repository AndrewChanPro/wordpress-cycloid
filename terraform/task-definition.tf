data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_caller_identity" "current" {}

locals {
  image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/cycloid_wordpress:latest"
}

resource "aws_ecs_task_definition" "task_def" {
  family                = "service"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    name  = "wordpress"
    image = local.image
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    environment = [
      {"name": "WORDPRESS_DB_HOST", "value": aws_db_instance.wordpress.endpoint},
      {"name": "WORDPRESS_DB_USER", "value": "root"},
      {"name": "WORDPRESS_DB_PASSWORD", "value": var.mysql_root_password},
      {"name": "WORDPRESS_DB_NAME", "value": var.mysql_db_name}
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/service"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}