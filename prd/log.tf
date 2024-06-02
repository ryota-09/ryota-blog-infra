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