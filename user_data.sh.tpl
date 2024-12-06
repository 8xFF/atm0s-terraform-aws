#!/bin/bash

STARTER=${start_id};
INDEX=$(curl -s http://169.254.169.254/latest/meta-data/ami-launch-index)
NODE_ID=$((STARTER + INDEX))
SERVICE_TYPE='${service_type}'

echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo ECS_INSTANCE_ATTRIBUTES="{\"service-type\": \"$SERVICE_TYPE\", \"node_id\": \"$NODE_ID\"}" >> /etc/ecs/ecs.config