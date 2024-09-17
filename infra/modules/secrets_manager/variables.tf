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
  default     = "RDS password"
  description = "Sensitive string to keep as secret."
}
