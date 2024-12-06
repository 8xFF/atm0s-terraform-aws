resource "aws_lb" "main_alb" {
  name               = "${var.env}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.env}-ecs-alb"
  }
}

resource "aws_lb_target_group" "gateway_ecs_target_group" {
  name        = "${var.env}-gateway-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # Since ECS is running on EC2

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-target-group"
  }
}

# Listener
resource "aws_lb_listener" "gateway_ecs_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_ecs_target_group.arn
  }

  tags = {
    Name = "gateway-ecs-listener"
  }
}

resource "aws_lb_target_group_attachment" "ecs_tg_attachment" {
  target_group_arn = aws_lb_target_group.gateway_ecs_target_group.arn
  target_id        = var.gateway_instance_id
  port             = 3000
}
