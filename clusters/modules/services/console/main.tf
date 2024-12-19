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
      "command" : ["--enable-interfaces", "eth0", "console"],
      "environment" : [
        {
          "name" : "HTTP_PORT",
          "value" : "80"
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
          "name" : "SDN_ZONE_NODE_ID_FROM_IP_PREFIX",
          "value" : "${var.subnet_cidr_prefix}"
        },
        {
          "name" : "WORKER",
          "value" : "2"
        },
        {
          "name" : "SECRET",
          "value" : "${var.cluster_secret}"
        },
        {
          "name" : "NODE_IP_ALT_CLOUD",
          "value" : "aws"
        },
        {
          "name" : "ENABLE_PRIVATE_IP",
          "value" : "true"
        },
        {
          "name" : "ENABLE_INTERFACES",
          "value" : "eth0"
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
    Name        = "console-task"
    environment = var.env
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
    Name        = "console-service"
    environment = var.env
  }
}
