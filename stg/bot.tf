resource "awscc_chatbot_slack_channel_configuration" "infra_chat_config" {
  configuration_name = "infra-chat-config-${local.env_name}"
  iam_role_arn       = awscc_iam_role.infra_chatbot_role.arn

  logging_level = "ERROR"

  slack_channel_id   = local.slack_channel_id
  slack_workspace_id = local.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.infra_chatbot_topic.arn]
}

resource "awscc_iam_role" "infra_chatbot_role" {
  role_name = "infra-chatbot-role-${local.env_name}"

  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"]
}

resource "aws_sns_topic" "infra_chatbot_topic" {
  name = "infra-chatbot-topic-${local.env_name}"
}
