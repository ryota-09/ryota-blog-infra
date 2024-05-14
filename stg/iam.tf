# data "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"
# }

# data "tls_certificate" "github_actions_oidc_provider" {
#   url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
# }

# resource "aws_iam_role" "github_actions" {
#   name               = "github-actions-${var.repo_name}"
#   assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
# }

# resource "aws_iam_policy" "github_actions_attachment_policy" {
#   name   = "github-actions-${var.repo_name}-attachment-policy"
#   policy = data.aws_iam_policy_document.github_actions_attachment_policy.json
# }

# data "aws_iam_policy_document" "github_actions_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     principals {
#       type        = "Federated"
#       identifiers = [data.aws_iam_openid_connect_provider.github.arn]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = ["repo:${var.repo_org}/${var.repo_name}:*"]
#     }
#   }
# }

# data "aws_iam_policy_document" "github_actions_attachment_policy" {
#   statement {
#     actions = [
#       "ecr:*"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy_attachment" "github_actions" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_attachment_policy.arn
# }

# resource "aws_iam_role" "apprunner" {
#   name               = "${var.repo_name}-apprunner"
#   assume_role_policy = data.aws_iam_policy_document.apprunner_principals.json
# }

# data "aws_iam_policy_document" "apprunner_principals" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "apprunner" {
#   role       = aws_iam_role.apprunner.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
# }
