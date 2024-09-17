output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.this.db_name
}

output "db_password" {
  value     = data.aws_secretsmanager_secret_version.latest.secret_string
  sensitive = true
}
