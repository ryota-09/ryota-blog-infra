output "APPRUNNER_URL" {
  value = aws_apprunner_service.apprunner.service_url
}

output "GUEST_ROLE_ARN" {
  value = aws_iam_role.guest_role.arn
}

output "IDENTITY_POOL_ID" {
  value = aws_cognito_identity_pool.id_pool.id
}

output "APPLICATION_ID" {
  value = aws_rum_app_monitor.frontend_rum.app_monitor_id
}

output "CLOUDFRONT_DISTRIBUTION_DOMAIN" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "CLOUDFRONT_DISTRIBUTION_ID" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}