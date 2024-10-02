output "secret_string" {
  value     = aws_secretsmanager_secret_version.latest.secret_string
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}