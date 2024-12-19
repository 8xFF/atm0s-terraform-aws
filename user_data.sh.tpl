#!/bin/bash

SERVICE_TYPE='${service_type}'

echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES="{\"service-type\": \"$SERVICE_TYPE\"}" >> /etc/ecs/ecs.config