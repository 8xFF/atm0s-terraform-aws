resource "aws_instance" "connector_instance" {
  ami             = var.ec2_ami
  key_name        = var.keypair_name
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  tags = {
    Name         = "connector-instance"
    service-type = "connector"
  }

  iam_instance_profile = var.ec2_iam_profile

  user_data = templatefile("${path.cwd}/user_data.sh.tpl", {
    ecs_cluster_name = var.ecs_cluster_name,
    service_type     = "connector"
  })
}

resource "aws_eip" "connector_eip" {
  domain = "vpc"
  tags = {
    Name = "connector-eip"
  }
}

resource "aws_eip_association" "connector_eip_association" {
  instance_id   = aws_instance.connector_instance.id
  allocation_id = aws_eip.connector_eip.id
}

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
            "name" : "SDN_ZONE_NODE_ID",
            "value" : "40"
          },
          {
            "name" : "SEEDS_FROM_URL",
            "value" : "${var.gateway_endpoint}/api/node/address"
          },
          {
            "name" : "WORKER",
            "value" : "2"
          },
          {
            "name" : "SECRET",
            "value" : "${var.cluster_secret}"
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
    Name = "connector-task"
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
