output "APPRUNNER_URL" {
  value = aws_apprunner_service.apprunner.service_url
}

output "GUEST_ROLE_ARN" {
  value = aws_iam_role.guest_role.arn
}

output "IDENTITY_POOL_ID" {
  value = aws_cognito_identity_pool.id_pool.id
}