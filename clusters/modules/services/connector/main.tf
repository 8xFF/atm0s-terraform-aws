resource "aws_cloudwatch_log_group" "log" {
  name              = "/${var.ecs_cluster_name}/connector-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "8xff-connector-task"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode(
    [
      {
        "name" : "8xff-connector",
        "image" : "${var.container_image}",
        "cpu" : 100,
        "memory" : 256,
        "command" : ["connector"],
        "environment" : [
          {
            "name" : "SDN_ZONE_ID",
            "value" : "${var.zone_id}"
          },
          {
            "name" : "SDN_ZONE_NODE_ID_FROM_IP_PREFIX",
            "value" : "${var.subnet_cidr_prefix}"
          },
          {
            "name" : "SEEDS_FROM_URL",
            "value" : "http://${var.gateway_endpoint}/api/node/address"
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
      }
    ]
  )
  tags = {
    Name        = "connector-task"
    environment = var.env
  }
}


resource "aws_ecs_service" "connector_service" {
  name            = "8xff-connector-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service-type == connector"
  }

  tags = {
    Name = "connector-service"
  }
}
