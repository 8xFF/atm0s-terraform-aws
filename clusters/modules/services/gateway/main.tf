resource "aws_cloudwatch_log_group" "log" {
  name              = "/${var.ecs_cluster_name}/gateway-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "8xff-gateway-task"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode(
    [
      {
        "name" : "8xff-gateway",
        "image" : "${var.container_image}",
        "cpu" : 100,
        "memory" : 256,
        "command" : ["gateway"],
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
            "value" : "${var.zone_id}"
          },
          {
            "name" : "SDN_ZONE_NODE_ID_FROM_IP_PREFIX",
            "value" : "${var.subnet_cidr_prefix}"
          },
          {
            "name" : "SEEDS_FROM_URL",
            "value" : "http://${var.console_endpoint}/api/cluster/seeds?zone_id=0&node_type=Gateway"
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
    Name        = "gateway-task"
    environment = var.env
  }
}


resource "aws_ecs_service" "gateway_service" {
  name            = "8xff-gateway-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service-type == gateway"
  }

  tags = {
    Name        = "gateway-service"
    environment = var.env
  }
}
