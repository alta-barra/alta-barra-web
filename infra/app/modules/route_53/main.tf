variable "domain_name" {
  type        = string
  description = "Domain name of the application. e.g. 'alta-barra.com'"
}

variable "namespace" {
  type        = string
  description = "Namespace the resource belong to. e.g. 'webapp'"
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

  tags = {
    Name = "${var.namespace}-certificate"
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]
}

resource "aws_route53_record" "generic_certificate_validation" {
  name    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.this.id
  records = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}

output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}

output "name" {
  value = data.aws_route53_zone.this.name
}
