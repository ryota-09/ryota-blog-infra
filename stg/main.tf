terraform {
  backend "s3" {
    bucket = "tf-state-ryota-blog-stg"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
  required_version = "~> 1.0"
}

resource "aws_ecr_repository" "ryota_blog" {
  name = local.repo_name
}

resource "aws_ecr_lifecycle_policy" "ryota_blog" {
  repository = aws_ecr_repository.ryota_blog.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 10,
      "description": "Expire images count more than 15",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 15
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
  EOF
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "tls_certificate" "github_actions_oidc_provider" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-${local.repo_name}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_policy" "github_actions_attachment_policy" {
  name   = "github-actions-${local.repo_name}-attachment-policy"
  policy = data.aws_iam_policy_document.github_actions_attachment_policy.json
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo_org}/${local.repo_name}:*"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_attachment_policy" {
  statement {
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_attachment_policy.arn
}

resource "aws_iam_role" "apprunner" {
  name               = "${local.repo_name}-apprunner"
  assume_role_policy = data.aws_iam_policy_document.apprunner_principals.json
}

data "aws_iam_policy_document" "apprunner_principals" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "apprunner" {
  role       = aws_iam_role.apprunner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "apprunner" {
  service_name = "${local.repo_name}-${local.env_name}"
  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner.arn
    }
    image_repository {
      image_configuration {
        port = 3000
        runtime_environment_variables = {
          HOSTNAME = "0.0.0.0"
        }
      }
      image_identifier      = "${aws_ecr_repository.ryota_blog.repository_url}:${local.image_tag}"
      image_repository_type = "ECR"
    }
  }

  network_configuration {}

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.apprunner.arn
}

resource "aws_apprunner_auto_scaling_configuration_version" "apprunner" {
  auto_scaling_configuration_name = local.repo_name

  max_concurrency = 50
  max_size        = 3
  min_size        = 1
}