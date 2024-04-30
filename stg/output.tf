output "GITHUB_ACTIONS_IAM_ROLE" {
  value = aws_iam_role.github_actions.arn
}

# output "APPRUNNER_URL" {
#   value = aws_apprunner_service.apprunner.service_url
# }