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
          HOSTNAME                = "0.0.0.0"
          NEXT_PUBLIC_BASE_URL    = local.base_url
          MICROCMS_SERVICE_DOMAIN = local.microcms_service_domain
          MICROCMS_API_KEY        = local.microcms_api_key
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

resource "aws_route53_zone" "main" {
  name = local.domain_name
}

resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Terraform   = local.repo_name
    Environment = terraform.workspace
  }
}

resource "aws_route53_record" "record" {
  for_each = {
    # dvo : domain validation option
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  name            = each.value.name
  zone_id         = aws_route53_zone.main.zone_id
  type            = each.value.type
  ttl             = 60

  records = [each.value.record]

  depends_on = [aws_acm_certificate.cert, aws_route53_zone.main]
}

# 追加のCNAMEレコード設定（証明書検証用）
resource "aws_route53_record" "cname_validation_a" {
  name    = local.cert_validation_record_name_a
  zone_id = aws_route53_zone.main.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [local.cert_validation_record_value_a]

  depends_on = [aws_apprunner_service.apprunner]
}
resource "aws_route53_record" "cname_validation_b" {
  name    = local.cert_validation_record_name_b
  zone_id = aws_route53_zone.main.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [local.cert_validation_record_value_b]

  depends_on = [aws_apprunner_service.apprunner]
}
resource "aws_route53_record" "cname_validation_c" {
  name    = local.cert_validation_record_name_c
  zone_id = aws_route53_zone.main.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [local.cert_validation_record_value_c]

  depends_on = [aws_apprunner_service.apprunner]
}

resource "aws_route53_record" "dns_a_record" {
  name    = local.dns_record_name
  zone_id = aws_route53_zone.main.zone_id
  type    = "A"

  alias {
    name                   = local.dns_record_value
    # NOTE: 参照 https://docs.aws.amazon.com/general/latest/gr/apprunner.html
    zone_id                = "Z08491812XW6IPYLR6CCA"
    evaluate_target_health = false
  }

  depends_on = [aws_apprunner_service.apprunner]
}



resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = flatten([values(aws_route53_record.record)[*].fqdn])

  depends_on = [aws_route53_record.record, aws_acm_certificate.cert]
}

resource "aws_apprunner_custom_domain_association" "apprunner_custom_domain" {
  service_arn = aws_apprunner_service.apprunner.arn
  domain_name = aws_acm_certificate.cert.domain_name
}
