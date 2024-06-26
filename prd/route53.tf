resource "aws_route53_zone" "main_prd" {
  name = var.domain_name
}

output "DOMAIN_NAME_SERVERS" {
  value = { for i, ns in aws_route53_zone.main_prd.name_servers : "nameserver_${i + 1}" => ns }
}

resource "aws_route53_record" "record_prd" {
  for_each = {
    # dvo : domain validation option
    for dvo in aws_acm_certificate.cert_prd.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  name            = each.value.name
  zone_id         = aws_route53_zone.main_prd.zone_id
  type            = each.value.type
  ttl             = 60

  records = [each.value.record]

  depends_on = [aws_acm_certificate.cert_prd, aws_route53_zone.main_prd]
}

# 追加のCNAMEレコード設定
resource "aws_route53_record" "cname_validation_a" {
  name    = var.cert_validation_record_name_a
  zone_id = aws_route53_zone.main_prd.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [var.cert_validation_record_value_a]

  depends_on = [aws_apprunner_service.apprunner]
}
resource "aws_route53_record" "cname_validation_b" {
  name    = var.cert_validation_record_name_b
  zone_id = aws_route53_zone.main_prd.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [var.cert_validation_record_value_b]

  depends_on = [aws_apprunner_service.apprunner]
}
resource "aws_route53_record" "cname_validation_c" {
  name    = var.cert_validation_record_name_c
  zone_id = aws_route53_zone.main_prd.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [var.cert_validation_record_value_c]

  depends_on = [aws_apprunner_service.apprunner]
}

resource "aws_route53_record" "dns_a_record" {
  name    = var.dns_record_name
  zone_id = aws_route53_zone.main_prd.zone_id
  type    = "A"

  alias {
    name = var.dns_record_value
    # NOTE: 参照 https://docs.aws.amazon.com/general/latest/gr/apprunner.html
    zone_id                = "Z08491812XW6IPYLR6CCA"
    evaluate_target_health = false
  }

  depends_on = [aws_apprunner_service.apprunner]
}