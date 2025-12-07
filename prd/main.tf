terraform {
  backend "s3" {
    bucket = "tf-state-ryota-blog-prd"
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

resource "aws_apprunner_service" "apprunner" {
  service_name = "${var.repo_name}-${var.env_name}"
  source_configuration {
    authentication_configuration {
      access_role_arn = var.apprunner_role_arn
    }
    image_repository {
      image_configuration {
        port = 3000
        runtime_environment_variables = {
          HOSTNAME                     = "0.0.0.0"
          NODE_ENV                     = "production"
          NEXT_PUBLIC_BASE_URL         = var.base_url
          MICROCMS_SERVICE_DOMAIN      = var.microcms_service_domain
          MICROCMS_API_KEY             = var.microcms_api_key
          NEXT_PUBLIC_GTM_ID           = var.gtm_id
          NEXT_PUBLIC_GA_ID            = var.ga_id
          NEXT_PUBLIC_GUEST_ROLE_ARN   = var.guest_role_arn
          NEXT_PUBLIC_IDENTITY_POOL_ID = var.identity_pool_id
          NEXT_PUBLIC_APPLICATION_ID   = var.application_id
        }
      }
      image_identifier      = "${var.image_uri}:${var.image_tag}"
      image_repository_type = "ECR"
    }
  }

  instance_configuration {
    cpu    = "0.25 vCPU"
    memory = "0.5 GB"
    # cpu    = 1024
    # memory = 2048
  }

  network_configuration {}

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.apprunner.arn
}

resource "aws_apprunner_auto_scaling_configuration_version" "apprunner" {
  auto_scaling_configuration_name = var.repo_name

  max_concurrency = 50
  max_size        = 3
  min_size        = 1
}

# CloudFront経由でアクセスするため、App Runnerカスタムドメインは不要
# resource "aws_apprunner_custom_domain_association" "apprunner_custom_domain" {
#   service_arn = aws_apprunner_service.apprunner.arn
#   domain_name = aws_acm_certificate.cert_prd.domain_name
# }

# 既存のManagedポリシーを参照（CloudFrontのデフォルトIDを使用）
data "aws_cloudfront_origin_request_policy" "all_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.repo_name}-${var.env_name} CloudFront Distribution"
  aliases         = [var.domain_name]

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
      value = var.cloudfront_secret_header_value
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

  # SSG/ISR JSONデータのキャッシュ（/_next/data/* にマッチ）
  ordered_cache_behavior {
    path_pattern     = "_next/data/*"
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
    Terraform   = var.repo_name
    Environment = var.env_name
  }
}
