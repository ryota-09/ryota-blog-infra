# resource "aws_cloudwatch_metric_alarm" "frontend_4xx_alarm" {
#   alarm_name          = "frontend-4xx-alarm-${local.env_name}"
#   alarm_description   = "frontend-4xx-alarm-${local.env_name}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "4xxStatusResponses"
#   namespace           = "AWS/AppRunner"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = "1"
#   dimensions = {
#     ServiceName = aws_apprunner_service.apprunner.service_name
#     ServiceId   = aws_apprunner_service.apprunner.service_id
#   }
#   alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
#   ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "frontend_5xx_alarm" {
#   alarm_name          = "frontend-5xx-alarm-${local.env_name}"
#   alarm_description   = "frontend-5xx-alarm-${local.env_name}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "5xxStatusResponses"
#   namespace           = "AWS/AppRunner"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = "1"
#   dimensions = {
#     ServiceName = aws_apprunner_service.apprunner.service_name
#     ServiceId   = aws_apprunner_service.apprunner.service_id
#   }
#   alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
#   ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "frontend_CPU_alarm" {
#   alarm_name          = "frontend-CPU-alarm-${local.env_name}"
#   alarm_description   = "frontend-CPU-alarm-${local.env_name}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/AppRunner"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "80"
#   dimensions = {
#     ServiceName = aws_apprunner_service.apprunner.service_name
#     ServiceId   = aws_apprunner_service.apprunner.service_id
#   }
#   alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
#   ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "frontend_Request_alarm" {
#   alarm_name          = "frontend-Request-alarm-${local.env_name}"
#   alarm_description   = "frontend-Request-alarm-${local.env_name}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "Requests"
#   namespace           = "AWS/AppRunner"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = "1"
#   dimensions = {
#     ServiceName = aws_apprunner_service.apprunner.service_name
#     ServiceId   = aws_apprunner_service.apprunner.service_id
#   }
#   alarm_actions             = [aws_sns_topic.infra_chatbot_topic.arn]
#   ok_actions                = [aws_sns_topic.infra_chatbot_topic.arn]
#   insufficient_data_actions = [aws_sns_topic.infra_chatbot_topic.arn]
# }