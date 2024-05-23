# provider "aws" {
#   alias = "virginia"
#   region = local.aws_region
# }

# resource "aws_route53_zone" "main" {
#   provider = aws.virginia
#   name     = local.domain_name
# }

# resource "aws_route53_record" "record" {
#   for_each = {
#     # dvo : domain validation option
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   zone_id         = aws_route53_zone.main.zone_id
#   type            = each.value.type
#   ttl             = 60

#   records = [each.value.record]

#   depends_on = [aws_acm_certificate.cert, aws_route53_zone.main]
# }

# resource "aws_acm_certificate" "cert" {
#   # provider          = aws.virginia
#   domain_name       = local.domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Terraform   = local.repo_name
#     Environment = terraform.workspace
#   }
# }

# resource "aws_acm_certificate_validation" "frontend_cert_validation" {
#   provider        = aws.virginia
#   certificate_arn = aws_acm_certificate.frontend_cert.arn

#   validation_record_fqdns = flatten([values(aws_route53_record.frontend_record)[*].fqdn])

#   depends_on = [aws_route53_record.frontend_record, aws_acm_certificate.frontend_cert]
# }
