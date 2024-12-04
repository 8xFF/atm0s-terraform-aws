resource "aws_instance" "console_instance" {
  ami             = var.ec2_ami
  key_name        = var.keypair_name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  tags = {
    Name         = "console-instance"
    service-type = "console"
  }

  iam_instance_profile = var.ec2_iam_profile

  user_data = templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "console"
  })
}

resource "aws_eip" "console_eip" {
  domain = "vpc"
  tags = {
    Name = "console-eip"
  }
}

resource "aws_eip_association" "console_eip_association" {
  instance_id   = aws_instance.console_instance.id
  allocation_id = aws_eip.console_eip.id
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/${var.ecs_cluster_name}/console-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "8xff-console-task"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode([
    {
      "name" : "8xff-console",
      "image" : "${var.container_image}",
      "cpu" : 100,
      "memory" : 256,
      "command" : ["console"],
      "environment" : [
        {
          "name" : "HTTP_PORT",
          "value" : "8080"
        },
        {
          "name" : "SDN_PORT",
          "value" : "10000"
        },
        {
          "name" : "SDN_ZONE_ID",
          "value" : tostring(var.zone_id)
        },
        {
          "name" : "SDN_ZONE_NODE_ID",
          "value" : "0"
        },
        {
          "name" : "WORKER",
          "value" : "2"
        }
      ]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.log.name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
  }])
  tags = {
    Name = "console-task"
  }
}

resource "aws_ecs_service" "console_service" {
  name            = "8xff-console-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service-type == console"
  }

  tags = {
    Name = "console-service"
  }
}
