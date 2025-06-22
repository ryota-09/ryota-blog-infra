resource "aws_wafv2_web_acl" "frontend_acl" {
  name  = "frontend-acl-${var.env_name}"
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
        search_string = var.cloudfront_secret_header_value
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
    metric_name                = "frontend-waf-${var.env_name}"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "frontend_acl_association" {
  resource_arn = aws_apprunner_service.apprunner.arn
  web_acl_arn  = aws_wafv2_web_acl.frontend_acl.arn
}