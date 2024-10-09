#!/bin/bash
# Install updates
yum update -y

# Install Docker
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# ECS configuration
echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config

# Install ECS agent
yum install -y ecs-init
service ecs start
chkconfig ecs on
