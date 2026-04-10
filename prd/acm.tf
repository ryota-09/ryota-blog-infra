# =============================================================================
# removed ブロック: ACM 証明書 (Cloudflare SSL に置換)
# =============================================================================

# App Runner 用 ACM 証明書 (ap-northeast-1)
removed {
  from = aws_acm_certificate.cert_prd
  lifecycle { destroy = false }
}

removed {
  from = aws_acm_certificate_validation.cert_validation_prd
  lifecycle { destroy = false }
}

# CloudFront 用 ACM 証明書 (us-east-1)
removed {
  from = aws_acm_certificate.cert_cloudfront
  lifecycle { destroy = false }
}

removed {
  from = aws_acm_certificate_validation.cert_validation_cloudfront
  lifecycle { destroy = false }
}
