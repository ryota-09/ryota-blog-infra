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

# CloudFront用のACM証明書 (us-east-1)
resource "aws_acm_certificate" "cert_cloudfront" {
  provider          = aws.virginia
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

# CloudFront用証明書の検証
resource "aws_acm_certificate_validation" "cert_validation_cloudfront" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.cert_cloudfront.arn

  validation_record_fqdns = flatten([values(aws_route53_record.record_cloudfront)[*].fqdn])

  depends_on = [aws_route53_record.record_cloudfront, aws_acm_certificate.cert_cloudfront]
}