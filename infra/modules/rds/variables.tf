variable "db_password_secret" {
  type        = string
  description = "Secret name for database credentials"
}

variable "db_username" {
  type        = string
  default     = "altabarra"
  description = "Username for the database."
}

variable "db_name" {
  type        = string
  description = "Name of the database to create when the DB instance is created"
  default     = "altabarra_db"
}

variable "db_identifier" {
  type        = string
  description = "Identifier for the RDS instance"
  default     = "altabarra-db"
}

variable "db_engine" {
  type        = string
  description = "The database engine to use"
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  description = "The engine version to use"
  default     = "16.3"
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
  default     = "db.t4g.micro"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security groups to associate"
  default     = []
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of DB subnet group"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment (e.g., development, production)"
  default     = "development"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Storage size in GB to allocate."
}
