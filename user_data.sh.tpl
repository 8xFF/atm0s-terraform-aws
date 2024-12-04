#!/bin/bash

## Configure cluster name using the template variable ${ecs_cluster_name}

echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES='{"service-type": "${service_type}"}' >> /etc/ecs/ecs.config 