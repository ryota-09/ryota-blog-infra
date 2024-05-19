output "GITHUB_ACTIONS_IAM_ROLE" {
  value = aws_iam_role.github_actions.arn
}

output "APPRUNNER_URL" {
  value = aws_apprunner_service.apprunner.service_url
}

output "CLOUDFRONT_DOMAIN_URL" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}

output "DOMAIN_NAME_SERVERS" {
  value = { for i, ns in aws_route53_zone.main.name_servers : "nameserver_${i + 1}" => ns }
}
