resource "aws_wafv2_web_acl" "frontend_acl" {
  name  = "frontend-acl-${var.env_name}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
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

    # NOTE: invaliderror を防ぐため
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