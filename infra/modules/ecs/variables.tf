variable "name" {
  type    = string
  default = "alta-barra"
}

variable "secrets_manager_arn" {
  type        = string
  description = "ARN of the secrets manager containing the DB credentials."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use"
}

variable "hash" {
  type = string
}
