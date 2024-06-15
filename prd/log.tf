resource "aws_cloudwatch_metric_alarm" "frontend_4xx_alarm" {
  alarm_name          = "frontend-4xx-alarm-${var.env_name}"
  alarm_description   = "frontend-4xx-alarm-${var.env_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxStatusResponses"
  namespace           = "AWS/AppRunner"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  dimensions = {
    ServiceName = aws_apprunner_service.apprunner.service_name
    ServiceId   = aws_apprunner_service.apprunner.service_id
  }
  alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
  ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
  insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_5xx_alarm" {
  alarm_name          = "frontend-5xx-alarm-${var.env_name}"
  alarm_description   = "frontend-5xx-alarm-${var.env_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "5xxStatusResponses"
  namespace           = "AWS/AppRunner"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  dimensions = {
    ServiceName = aws_apprunner_service.apprunner.service_name
    ServiceId   = aws_apprunner_service.apprunner.service_id
  }
  alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
  ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
  insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "first_input_delay_alarm" {
  alarm_name          = "first-input-delay-alarm-${var.env_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FirstInputDelay"
  namespace           = "AWS/RUM"
  statistic           = "Average"
  threshold           = "200"
  period              = "300"
  alarm_description   = "Alert when First Input Delay exceeds 200ms"
  # actions_enabled     = true

  alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
  ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
  insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
  dimensions = {
    AppMonitorName = aws_rum_app_monitor.frontend_rum.name
  }
}

# RUM (Real User Monitoring) 
resource "aws_rum_app_monitor" "frontend_rum" {
  name           = "frontend-rum-${var.env_name}"
  domain         = var.domain_name
  # cw_log_enabled = true

  app_monitor_configuration {
    allow_cookies       = true
    enable_xray         = false
    identity_pool_id    = aws_cognito_identity_pool.id_pool.id
    session_sample_rate = 1
    telemetries = [
      "errors",
      "http",
      "performance"
    ]
  }
}

resource "aws_cognito_identity_pool" "id_pool" {
  identity_pool_name = "id-pool-${var.env_name}"
  # NOTE: guset access
  allow_unauthenticated_identities = true
  allow_classic_flow               = true
}

resource "aws_cognito_identity_pool_roles_attachment" "guest_attachment" {
  identity_pool_id = aws_cognito_identity_pool.id_pool.id

  roles = {
    "unauthenticated" = aws_iam_role.guest_role.arn
  }
}

resource "aws_iam_policy" "guest_policy" {
  name = "guest-policy-${var.env_name}"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        Action = [
          "rum:PutRumEvents",
        ]
        "Resource" : aws_rum_app_monitor.frontend_rum.arn
      }
    ]
  })

}

resource "aws_iam_role" "guest_role" {
  name = "guest-role-${var.env_name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "cognito-identity.amazonaws.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "cognito-identity.amazonaws.com:aud" : aws_cognito_identity_pool.id_pool.id
          },
          "ForAnyValue:StringLike" : {
            "cognito-identity.amazonaws.com:amr" : "unauthenticated"
          }
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.guest_policy.arn]
}
