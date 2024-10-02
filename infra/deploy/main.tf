provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "elixir_app_bucket" {
  bucket = "alta-barra-app-deployments-bucket"
  acl    = "private"
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "Allow EC2 instances to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.elixir_app_bucket.arn}",
          "${aws_s3_bucket.elixir_app_bucket.arn}/*",
        ],
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_s3_access" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}