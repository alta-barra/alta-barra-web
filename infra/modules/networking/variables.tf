########################################################################################################################
## module variables
########################################################################################################################
variable "namespace" {
  description = "Namespace for resource names"
  default     = "AltaBarra"
  type        = string
}

variable "environment" {
  description = "Environment for deployment (like dev or staging)"
  default     = "dev"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = "Base tags applied to all resources"
}

########################################################################################################################
## network variables
########################################################################################################################
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  default     = "10.1.0.0/16"
  type        = string
}

variable "az_count" {
  description = "Describes how many availability zones are used"
  default     = 2
  type        = number
}
