resource "aws_ecs_cluster" "main" {
  name = "jacopen-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "webservices" {
  name            = "webservices"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id]

    subnets = [
      data.aws_subnet.private_0.id,
      data.aws_subnet.private_1.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "first"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "httpd:latest"
      essential = true
      portMappings = [
        {
          protocol      = "tcp",
          containerPort = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/jacopen-ecs/webservices",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
