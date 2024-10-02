#!/bin/bash
# Update the system
yum update -y

# Install curl
yum install -y curl tar

# Install Erlang
# Add the RabbitMQ repository for Erlang (uses a common repo)
cat <<EOF | sudo tee /etc/yum.repos.d/rabbitmq_erlang.repo
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packages.rabbitmq.com/erlang/rpm/amazon/2/\$basearch
gpgcheck=1
gpgkey=https://packages.rabbitmq.com/rabbitmq-release-signing-key.asc
enabled=1
EOF

sudo yum install -y erlang

# Install Elixir
# Add the Erlang Solutions repository for Elixir
cat <<EOF | sudo tee /etc/yum.repos.d/erlang_solutions.repo
[erlang_solutions]
name=CentOS 7 repository for erlang-solutions packages
baseurl=https://packages.erlang-solutions.com/rpm/centos/7/\$basearch
gpgcheck=1
gpgkey=https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
EOF

sudo yum install -y elixir

aws s3 cp s3://${app_bucket}/app.tar.gz /tmp/app.tar.gz
mkdir -p /var/www/elixir_app
tar -xzf /tmp/app.tar.gz -C /var/www/elixir_app
# Restart application (assuming systemd)
systemctl restart elixir_app.service
