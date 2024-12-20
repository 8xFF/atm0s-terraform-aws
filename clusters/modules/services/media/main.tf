resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.autoscale_group_arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}


resource "aws_cloudwatch_log_group" "log" {
  name              = "/${var.ecs_cluster_name}/media-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "8xff-media-task"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  container_definitions = jsonencode(
    [
      {
        "name" : "8xff-media",
        "image" : "${var.container_image}",
        "cpu" : 100,
        "memory" : 256,
        "command" : ["media"],
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
    Name = "media-task"
  }
}


resource "aws_ecs_service" "media_service" {
  name            = "8xff-media-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service-type == media"
  }

  tags = {
    Name        = "media-service"
    environment = var.env
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }
}


resource "aws_appautoscaling_target" "media_scale_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.media_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "media-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.media_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.media_scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.media_scale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "media-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.media_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.media_scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.media_scale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }

  depends_on = [aws_appautoscaling_policy.ecs_policy_memory]
}
