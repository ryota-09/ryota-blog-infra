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
          HOSTNAME = "0.0.0.0"
          NEXT_PUBLIC_BASE_URL    = var.base_url
          MICROCMS_SERVICE_DOMAIN = var.microcms_service_domain
          MICROCMS_API_KEY        = var.microcms_api_key
          NEXT_PUBLIC_GTM_ID      = var.gtm_id
          NEXT_PUBLIC_GA_ID       = var.ga_id
        }
      }
      image_identifier      = "${var.image_uri}:${var.image_tag}"
      image_repository_type = "ECR"
    }
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

resource "aws_apprunner_custom_domain_association" "apprunner_custom_domain" {
  service_arn = aws_apprunner_service.apprunner.arn
  domain_name = aws_acm_certificate.cert_prd.domain_name
}