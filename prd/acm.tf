resource "aws_acm_certificate" "cert_prd" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Terraform   = var.repo_name
    Environment = terraform.workspace
  }
}

resource "aws_acm_certificate_validation" "cert_validation_prd" {
  certificate_arn = aws_acm_certificate.cert_prd.arn

  validation_record_fqdns = flatten([values(aws_route53_record.record_prd)[*].fqdn])

  depends_on = [aws_route53_record.record_prd, aws_acm_certificate.cert_prd]
}