# Route53 Zone はロールバック用に保持
# NS が Cloudflare に向くため、通常時はアクティブに使用されない
resource "aws_route53_zone" "main_prd" {
  name = var.domain_name
}

# =============================================================================
# removed ブロック: Route53 レコード
# =============================================================================

# ACM 証明書検証レコード (App Runner用)
removed {
  from = aws_route53_record.record_prd
  lifecycle { destroy = false }
}

# ACM 証明書検証レコード (CloudFront用)
removed {
  from = aws_route53_record.record_cloudfront
  lifecycle { destroy = false }
}

# CNAME validation records
removed {
  from = aws_route53_record.cname_validation_a
  lifecycle { destroy = false }
}

removed {
  from = aws_route53_record.cname_validation_b
  lifecycle { destroy = false }
}

removed {
  from = aws_route53_record.cname_validation_c
  lifecycle { destroy = false }
}

# CloudFront 向け A レコード
removed {
  from = aws_route53_record.dns_a_record
  lifecycle { destroy = false }
}

# Storybook CNAME (Cloudflare DNS に移行)
removed {
  from = aws_route53_record.story_cname
  lifecycle { destroy = false }
}
