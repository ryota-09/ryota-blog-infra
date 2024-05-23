# resource "aws_cloudfront_cache_policy" "with_query_params" {
#   name        = "with_query_params"
#   default_ttl = 1
#   max_ttl     = 1
#   min_ttl     = 1
#   parameters_in_cache_key_and_forwarded_to_origin {
#     cookies_config {
#       cookie_behavior = "none"
#     }
#     headers_config {
#       header_behavior = "whitelist"
#       headers {
#         items = [
#           "Origin",
#           "Access-Control-Request-Method",
#           "Access-Control-Request-Headers",
#           "Content-Type",
#           "Authorization",
#           "Accept",
#           "Access-Control-Allow-Origin",
#           "Access-Control-Allow-Methods",
#           "Access-Control-Allow-Headers"
#         ]
#       }
#     }
#     query_strings_config {
#       query_string_behavior = "all"
#     }
#   }
# }

# locals {
#   managed_caching_optimized_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
#   managed_caching_disabled_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
# }

# resource "aws_cloudfront_distribution" "frontend_cdn" {
#   enabled         = true
#   is_ipv6_enabled = false
#   origin {
#     origin_id   = aws_apprunner_service.apprunner.service_name
#     domain_name = aws_apprunner_service.apprunner.service_url
#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "https-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }
#   default_cache_behavior {
#     target_origin_id       = aws_apprunner_service.apprunner.service_name
#     viewer_protocol_policy = "https-only"
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     cache_policy_id        = local.managed_caching_disabled_policy_id
#     compress               = true
#   }

#   ordered_cache_behavior {
#     path_pattern           = "/blogs?*"
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = aws_apprunner_service.apprunner.service_name
#     viewer_protocol_policy = "https-only"
#     cache_policy_id        = aws_cloudfront_cache_policy.with_query_params.id
#     compress               = true
#   }

#   ordered_cache_behavior {
#     path_pattern           = "/blogs/*"
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = aws_apprunner_service.apprunner.service_name
#     viewer_protocol_policy = "https-only"
#     cache_policy_id        = local.managed_caching_optimized_policy_id
#     compress               = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     # cloudfront_default_certificate = true
#     acm_certificate_arn = aws_acm_certificate_validation.frontend_cert_validation.certificate_arn
#   }
# }

# #Aliasレコード
# resource "aws_route53_record" "frontend_alias_record" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = local.domain_name
#   type    = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

