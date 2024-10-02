variable "secret_name" {
  type        = string
  description = "Name of the secret."
}

variable "kms_key_id" {
  type        = string
  description = "ID of the KMS key to use."
}

variable "description" {
  type        = string
  default     = "Password for RDS"
  description = "Sensitive string to keep as secret."
}

variable "environment" {
  type        = string
  description = "Environment this secret is for."
}

variable "namespace" {
  type        = string
  description = "Namespace to categorize."
}
