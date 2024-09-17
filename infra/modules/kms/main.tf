resource "aws_kms_key" "this" {
  description             = "KMS key for RDS"
  deletion_window_in_days = var.deletion_window_in_days
  is_enabled              = true
  enable_key_rotation     = true
  tags = {
    Name = "${var.namespace}_terraform_aws_rds_secrets_manager"
  }
}
