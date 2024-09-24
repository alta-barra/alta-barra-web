resource "aws_db_instance" "this" {
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  identifier              = var.db_identifier
  instance_class          = var.instance_class
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.${var.db_engine}${split(".", var.db_engine_version)[0]}"
  skip_final_snapshot     = true
  apply_immediately       = true
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  storage_encrypted       = true

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  deletion_protection = var.environment == "production" ? true : false

  tags = {
    Name        = var.db_identifier
    Environment = var.environment
  }
}
