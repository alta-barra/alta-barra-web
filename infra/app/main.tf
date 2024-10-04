# Terraform

## AWS Data ==================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2_free_tier" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Free Tier eligible Amazon Linux 2 AMI
  }

  owners = ["amazon"]
}

## Route53 Hosted Zone  ======================================================
module "route_53" {
  source      = "./modules/route_53/"
  domain_name = var.domain_name
  namespace   = var.namespace
}

## Networking ================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.namespace}_VPC_${var.environment}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.namespace}_InternetGateway_${var.environment}"
  }
}

resource "aws_subnet" "public" {
  for_each = { for i, az in data.aws_availability_zones.available.names : az => i }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.az_count + each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.namespace}_PublicSubnet_${each.key}_${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.namespace}_PublicRouteTable_${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_gateway" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "${var.namespace}_EIP_${each.key}_${var.environment}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = aws_subnet.public

  subnet_id     = each.value.id
  allocation_id = aws_eip.nat_gateway[each.key].id

  tags = {
    Name = "${var.namespace}_NATGateway_${each.key}_${var.environment}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for i, az in data.aws_availability_zones.available.names : az => i }

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, each.value)
  availability_zone = each.key

  tags = {
    Name = "${var.namespace}_PrivateSubnet_${each.key}_${var.environment}"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }

  tags = {
    Name = "${var.namespace}_PrivateRouteTable_${each.key}_${var.environment}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_key_pair" "default" {
  key_name   = "${var.namespace}_KeyPair_${var.environment}"
  public_key = var.public_ec2_key
}

resource "aws_iam_role" "ec2_instance_role" {
  name               = "${var.namespace}_EC2_InstanceRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name = "${var.namespace}_EC2_InstanceRoleProfile_${var.environment}"
  role = aws_iam_role.ec2_instance_role.id
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

## Secrets ===================================================================
module "kms" {
  source    = "./modules/kms"
  namespace = var.namespace
}

module "secrets_manager" {
  source      = "./modules/secrets_manager/"
  secret_name = "${var.namespace}/${var.environment}/db_password"
  kms_key_id  = module.kms.key_id
  description = "Password for RDS"
  environment = var.environment
  namespace   = var.namespace
}

## RDS =======================================================================
resource "aws_db_subnet_group" "default" {
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.namespace}_db_subnet_group_${var.environment}"
  }
}

module "rds" {
  source = "./modules/rds"

  db_password            = module.secrets_manager.secret_string
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.namespace}_ECS_ServiceRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.namespace}_ECS_ServiceRolePolicy_${var.environment}"
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  role   = aws_iam_role.ecs_service_role.id
}

data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutSubscriptionFilter",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${lower(var.namespace)}/ec2/${var.service_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.namespace}_ECS_TaskExecutionRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "read_secrets_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.secrets_manager.secret_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.kms.key_arn]
  }
}

resource "aws_iam_policy" "read_secrets_policy" {
  name   = "${var.namespace}_ReadSecretsPolicy_${var.environment}"
  policy = data.aws_iam_policy_document.read_secrets_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.read_secrets_policy.arn
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "${var.namespace}_ECS_TaskIAMRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

resource "aws_alb" "alb" {
  name            = "${var.namespace}-ALB-${var.environment}"
  security_groups = [aws_security_group.alb.id]
  subnets         = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = module.route_53.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_target_group.arn
  }

  depends_on = [module.route_53]
}

resource "aws_alb_listener" "http_redirect_to_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_target_group" "service_target_group" {
  name                 = "${var.namespace}-TG-${var.environment}"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 120

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    matcher             = var.healthcheck_matcher
    path                = var.healthcheck_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "30"
  }

  depends_on = [aws_alb.alb]
}

resource "aws_lb_target_group" "application_tg" {
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.namespace}_ALB_SecurityGroup_${var.environment}"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.namespace}_ALB_SecurityGroup_${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_inbound" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # Public access
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_inbound" {
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # Public access
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_egress" {
  security_group_id = aws_security_group.alb.id
  from_port         = 1024
  to_port           = 65535
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_http_egress" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Security Group for ECS Instances
resource "aws_security_group" "ecs_instances" {
  name        = "${var.namespace}_ECS_Instance_SecurityGroup_${var.environment}"
  description = "Security group for EC2 instances in ECS cluster"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.namespace}_EC2_Instance_SecurityGroup_${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_ingress" {
  security_group_id = aws_security_group.ecs_instances.id
  from_port         = 1024
  to_port           = 65535
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-SGR-ecs-alb-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_http_ingress" {
  security_group_id = aws_security_group.ecs_instances.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-SGR-ecs-alb-http-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_https_ingress" {
  security_group_id = aws_security_group.ecs_instances.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-SGR-ecs-alb-https-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ssh_ingress" {
  security_group_id = aws_security_group.ecs_instances.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-SGR-ecs-ssh-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_instances.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.environment}-SGR-ecs-egress"
  }
}

# Security Group for Bastion
resource "aws_security_group" "bastion_host" {
  name        = "${var.namespace}_SecurityGroup_BastionHost_${var.environment}"
  description = "Bastion host Security Group"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_s3_bucket" "elixir_app_bucket" {
  bucket = var.app_bucket
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "s3_and_secrets_access_policy" {
  name        = "s3_and_secrets_access_policy"
  description = "Allow EC2 instances to access S3 bucket and Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "${data.aws_s3_bucket.elixir_app_bucket.arn}",
          "${data.aws_s3_bucket.elixir_app_bucket.arn}/*",
        ],
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_s3_access" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_and_secrets_access_policy.arn
}

resource "aws_instance" "elixir_app_server" {
  count                       = 1
  ami                         = data.aws_ami.amazon_linux_2_free_tier.id
  instance_type               = "t2.micro"
  subnet_id                   = values(aws_subnet.public)[0].id # TODO change this if more are needed
  associate_public_ip_address = true
  key_name                    = aws_key_pair.default.id
  vpc_security_group_ids      = [aws_security_group.ecs_instances.id]
  iam_instance_profile        = aws_iam_role.ec2_s3_access_role.name

  user_data = base64encode(templatefile("./modules/ecs/user_data.sh", { sha_hash = var.hash, app_bucket = var.app_bucket }))

  tags = {
    Name = "${var.namespace}_EC2_WebHost_${var.environment}"
  }
}

resource "aws_instance" "bastion_host" {
  count                       = 0
  ami                         = data.aws_ami.amazon_linux_2_free_tier.id
  instance_type               = "t2.micro"
  subnet_id                   = values(aws_subnet.public)[0].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.default.id
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]

  tags = {
    Name = "${var.namespace}_EC2_BastionHost_${var.environment}"
  }
}

resource "aws_route53_record" "www" {
  name    = module.route_53.name
  type    = "A"
  zone_id = module.route_53.zone_id

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_role_policy" "ecs_task_rds_access" {
  name = "${var.namespace}_ECS_TaskRDSAccess_${var.environment}"
  role = aws_iam_role.ecs_task_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "${module.rds.db_instance_arn}"
        ]
      }
    ]
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.namespace}_RDS_SecurityGroup_${var.environment}"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.namespace}_RDS_SecurityGroup_${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs_ingress" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL access from ECS instances"

  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
  cidr_ipv4   = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-SGR-rds-from-ecs-ingress"
  }
}
