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
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.78.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.7.0"
}

# =============================================================================
# removed ブロック: AWS リソースを Terraform 管理から切り離す
# lifecycle { destroy = false } → AWS 上にリソースは残るが Terraform では管理しない
# 安定稼働確認後、destroy = true に変更して実際に削除する
# =============================================================================

# --- ECR ---
removed {
  from = aws_ecr_repository.ryota_blog
  lifecycle { destroy = false }
}

removed {
  from = aws_ecr_lifecycle_policy.ryota_blog
  lifecycle { destroy = false }
}

# --- App Runner ---
removed {
  from = aws_apprunner_service.apprunner
  lifecycle { destroy = false }
}

removed {
  from = aws_apprunner_auto_scaling_configuration_version.apprunner
  lifecycle { destroy = false }
}

# --- IAM (GitHub Actions OIDC + App Runner) ---
removed {
  from = aws_iam_role.github_actions
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_policy.github_actions_attachment_policy
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role_policy_attachment.github_actions
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role.apprunner
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role_policy_attachment.apprunner
  lifecycle { destroy = false }
}

# --- Route53 ---
removed {
  from = aws_route53_zone.main
  lifecycle { destroy = false }
}

# --- ACM 証明書 ---
removed {
  from = aws_acm_certificate.cert
  lifecycle { destroy = false }
}

removed {
  from = aws_acm_certificate.cert_cloudfront
  lifecycle { destroy = false }
}

removed {
  from = aws_acm_certificate_validation.cert_validation
  lifecycle { destroy = false }
}

removed {
  from = aws_acm_certificate_validation.cert_validation_cloudfront
  lifecycle { destroy = false }
}

# --- Route53 レコード ---
removed {
  from = aws_route53_record.record
  lifecycle { destroy = false }
}

removed {
  from = aws_route53_record.record_cloudfront
  lifecycle { destroy = false }
}

removed {
  from = aws_route53_record.dns_a_record
  lifecycle { destroy = false }
}

# --- CloudFront ---
removed {
  from = aws_cloudfront_distribution.main
  lifecycle { destroy = false }
}

# --- Chatbot / SNS ---
removed {
  from = awscc_chatbot_slack_channel_configuration.infra_chat_config
  lifecycle { destroy = false }
}

removed {
  from = awscc_iam_role.infra_chatbot_role
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_policy.cloudwatch_access_policy
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role_policy_attachment.cloudwatch_access_attachment
  lifecycle { destroy = false }
}

removed {
  from = aws_sns_topic.infra_chatbot_topic
  lifecycle { destroy = false }
}
