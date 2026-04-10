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
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.0.0"
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
#
# 削除順序（依存関係のリーフから）:
#   Phase A: CloudWatch alarms, Storybook CNAME, CNAME validation records
#   Phase B: DNS A record (CloudFront 依存)
#   Phase C: WAF Association (App Runner 依存)
#   Phase D: CloudFront (enabled=false 後に削除)
#   Phase E: WAF ACL
#   Phase F: ACM 証明書 + 検証
#   Phase G: App Runner + Auto Scaling
#   Phase H: 監視スタック (RUM, Cognito, IAM, Chatbot, SNS)
#   Phase I: Route53 Zone (ロールバック完全終了後)
# =============================================================================

# --- App Runner ---
removed {
  from = aws_apprunner_service.apprunner
  lifecycle { destroy = false }
}

removed {
  from = aws_apprunner_auto_scaling_configuration_version.apprunner
  lifecycle { destroy = false }
}

# --- CloudFront ---
# 注意: 実際に削除する際は enabled=false にしてから apply し、
# propagation 完了 (15-30分) 後に destroy = true に変更すること
removed {
  from = aws_cloudfront_distribution.main
  lifecycle { destroy = false }
}
