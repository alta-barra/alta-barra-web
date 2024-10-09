terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "alta-barra-iac"
    key            = "alta-barra-website/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

