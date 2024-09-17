resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  kms_key_id              = var.kms_key_id
  description             = var.description
  recovery_window_in_days = 14

  tags = {
    Name = "terraform_aws_rds_secrets_manager"
  }
}

resource "aws_secretsmanager_secret_version" "latest" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.password.result
}
