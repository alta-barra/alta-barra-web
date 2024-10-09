########################################################################################################################
## Service variables
########################################################################################################################
variable "namespace" {
  description = "Namespace for resource names"
  default     = "AltaBarra"
  type        = string
}

variable "domain_name" {
  description = "Domain name of the service (like service.example.com)"
  type        = string
}

variable "service_name" {
  description = "A Docker image-compatible name for the service"
  type        = string
}

variable "environment" {
  description = "Environment for deployment (like dev or staging)"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Base tags applied to all resources"
}

variable "secret_key_base" {
  description = "Phoenix secret key"
  type        = string
}

variable "hash" {
  description = "Image hash to deploy"
  type        = string
}

########################################################################################################################
## AWS variables
########################################################################################################################
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

########################################################################################################################
## Network variables
########################################################################################################################

variable "tld_zone_id" {
  description = "Top level domain hosted zone ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  type        = string
}

########################################################################################################################
## EC2 Computing variables
########################################################################################################################

variable "public_ec2_key" {
  description = "Public key for SSH access to EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t3.micro"
  type        = string
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 4000
}

variable "cpu_units" {
  description = "Amount of CPU units for a single ECS task"
  default     = 100
  type        = number
}

variable "memory" {
  description = "Amount of memory in MB for a single ECS task"
  default     = 256
  type        = number
}

########################################################################################################################
## Cloudwatch
########################################################################################################################

variable "retention_in_days" {
  description = "Retention period for Cloudwatch logs"
  default     = 7
  type        = number
}

########################################################################################################################
## ECR
########################################################################################################################

variable "ecr_force_delete" {
  description = "Forces deletion of Docker images before resource is destroyed"
  default     = true
  type        = bool
}

########################################################################################################################
## Autoscaling Group
########################################################################################################################

variable "autoscaling_max_size" {
  description = "Max size of the autoscaling group"
  default     = 5
  type        = number
}

variable "autoscaling_min_size" {
  description = "Min size of the autoscaling group"
  default     = 1
  type        = number
}
