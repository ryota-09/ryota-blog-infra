# CloudWatch アクセス用のポリシー定義
data "aws_iam_policy_document" "cloudwatch_access" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:SetAlarmState"
    ]
  }
}

# CloudWatch アクセスポリシーを作成
resource "aws_iam_policy" "cloudwatch_access_policy" {
  name   = "cloudwatch-access-policy-${var.env_name}"
  policy = data.aws_iam_policy_document.cloudwatch_access.json
}

# Chatbot IAM ロールに CloudWatch アクセスポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "cloudwatch_access_attachment" {
  role       = awscc_iam_role.infra_chatbot_role.role_name
  policy_arn = aws_iam_policy.cloudwatch_access_policy.arn
}

# Chatbot Slack Channel Configuration の修正
resource "awscc_chatbot_slack_channel_configuration" "infra_chat_config" {
  configuration_name = "infra-chat-config-${var.env_name}"
  iam_role_arn       = awscc_iam_role.infra_chatbot_role.arn
  logging_level      = "ERROR"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.infra_chatbot_topic.arn]
}

# Chatbot IAM ロールの定義
resource "awscc_iam_role" "infra_chatbot_role" {
  role_name = "infra-chatbot-role-${var.env_name}"
  assume_role_policy_document = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"]
}

# Chatbot SNS トピックの定義
resource "aws_sns_topic" "infra_chatbot_topic" {
  name = "infra-chatbot-topic-${var.env_name}"
}

