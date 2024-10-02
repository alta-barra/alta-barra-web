resource "aws_ecr_repository" "this" {
  name         = var.repo_name
  force_delete = var.environment == "production" ? false : true

  image_scanning_configuration {
    scan_on_push = true
  }
}
