resource "aws_lb" "main" {
  name               = "jacopen-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [data.aws_subnet.public_0.id, data.aws_subnet.public_1.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name        = "jacopen-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
