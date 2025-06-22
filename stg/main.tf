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

# Provider for us-east-1 (CloudFront ACM証明書用)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_ecr_repository" "ryota_blog" {
  name         = local.repo_name
  force_delete = true
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

# 既存のManagedポリシーを参照（CloudFrontのデフォルトIDを使用）
data "aws_cloudfront_origin_request_policy" "all_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
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
          HOSTNAME                     = "0.0.0.0"
          NEXT_PUBLIC_BASE_URL         = "https://domain-test-ryota-09.click"
          MICROCMS_SERVICE_DOMAIN      = local.microcms_service_domain
          MICROCMS_API_KEY             = local.microcms_api_key
          NEXT_PUBLIC_GTM_ID           = local.gtm_id
          NEXT_PUBLIC_GA_ID            = local.ga_id
          NEXT_PUBLIC_GUEST_ROLE_ARN   = local.guest_role_arn
          NEXT_PUBLIC_IDENTITY_POOL_ID = local.identity_pool_id
          NEXT_PUBLIC_APPLICATION_ID   = local.application_id
        }
      }
      image_identifier      = "042313712092.dkr.ecr.ap-northeast-1.amazonaws.com/ryota-blog:stg"
      image_repository_type = "ECR"
    }
  }

  network_configuration {}

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.apprunner.arn
}

resource "aws_apprunner_auto_scaling_configuration_version" "apprunner" {
  auto_scaling_configuration_name = "${local.repo_name}-${local.env_name}"

  max_concurrency = 50
  max_size        = 3
  min_size        = 1
}

resource "aws_route53_zone" "main" {
  name = local.domain_name
}

# App Runner用のACM証明書 (ap-northeast-1)
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

# CloudFront用のACM証明書 (us-east-1)
resource "aws_acm_certificate" "cert_cloudfront" {
  provider          = aws.virginia
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

# App Runner用証明書の検証レコード
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

# CloudFront用証明書の検証レコード
resource "aws_route53_record" "record_cloudfront" {
  for_each = {
    # dvo : domain validation option
    for dvo in aws_acm_certificate.cert_cloudfront.domain_validation_options : dvo.domain_name => {
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

  depends_on = [aws_acm_certificate.cert_cloudfront, aws_route53_zone.main]
}

# 証明書検証用CNAMEレコードはACMが自動的に作成するため不要

resource "aws_route53_record" "dns_a_record" {
  name    = local.dns_record_name
  zone_id = aws_route53_zone.main.zone_id
  type    = "A"

  alias {
    name = local.dns_record_value
    # NOTE: CloudFront Distribution Zone ID
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }

  depends_on = [aws_apprunner_service.apprunner]
}



# App Runner用証明書の検証
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = flatten([values(aws_route53_record.record)[*].fqdn])

  depends_on = [aws_route53_record.record, aws_acm_certificate.cert]
}

# CloudFront用証明書の検証
resource "aws_acm_certificate_validation" "cert_validation_cloudfront" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.cert_cloudfront.arn

  validation_record_fqdns = flatten([values(aws_route53_record.record_cloudfront)[*].fqdn])

  depends_on = [aws_route53_record.record_cloudfront, aws_acm_certificate.cert_cloudfront]
}

# App Runnerカスタムドメインは不要（CloudFront経由でアクセス）
# resource "aws_apprunner_custom_domain_association" "apprunner_custom_domain" {
#   service_arn = aws_apprunner_service.apprunner.arn
#   domain_name = aws_acm_certificate.cert.domain_name
# }

# WAF Web ACL for App Runner - CloudFront経由のみアクセス許可
resource "aws_wafv2_web_acl" "frontend_acl" {
  name  = "frontend-acl-${local.env_name}"
  scope = "REGIONAL"

  # デフォルトでブロック
  default_action {
    block {}
  }

  # CloudFrontからのアクセスのみ許可
  rule {
    name     = "AllowCloudFrontOnly"
    priority = 1

    statement {
      byte_match_statement {
        search_string = local.cloudfront_secret_header_value
        field_to_match {
          single_header {
            name = "x-cloudfront-secret"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
        positional_constraint = "EXACTLY"
      }
    }

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowCloudFrontOnly"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-aws-managed-rules-common-rule-set"
      sampled_requests_enabled   = true
    }

    override_action {
      none {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "frontend-waf-${local.env_name}"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "frontend_acl_association" {
  resource_arn = aws_apprunner_service.apprunner.arn
  web_acl_arn  = aws_wafv2_web_acl.frontend_acl.arn
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${local.repo_name}-${local.env_name} CloudFront Distribution"
  aliases         = [local.domain_name]

  # App Runner Origin
  origin {
    domain_name = replace(aws_apprunner_service.apprunner.service_url, "https://", "")
    origin_id   = "AppRunnerOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # CloudFront専用のカスタムヘッダーを追加
    custom_header {
      name  = "x-cloudfront-secret"
      value = local.cloudfront_secret_header_value
    }
  }

  # Default Cache Behavior for dynamic content
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    # App Runner向けにHostヘッダーを書き換えるポリシー
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Cache behavior for static assets - Images
  ordered_cache_behavior {
    path_pattern     = "*.jpg"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.jpeg"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.png"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.gif"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.webp"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Cache behavior for CSS and JS
  ordered_cache_behavior {
    path_pattern     = "*.css"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.js"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # 画像最適化用のキャッシュビヘイビア（/_next/image にマッチ）
  ordered_cache_behavior {
    path_pattern     = "_next/image*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    # Hostヘッダー書き換えポリシー
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id
    # 動的画像なのでキャッシュを無効化する（Managed-CachingDisabledポリシー等）
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # 静的アセットのキャッシュ
  ordered_cache_behavior {
    path_pattern     = "_next/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "AppRunnerOrigin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_except_host.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  price_class = "PriceClass_200" # Use only North America, Europe, Asia, Middle East, and Africa edge locations

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert_cloudfront.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Terraform   = local.repo_name
    Environment = local.env_name
  }
}

# Output for CloudFront distribution
output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "app_runner_service_url" {
  description = "App Runner service URL"
  value       = aws_apprunner_service.apprunner.service_url
}
