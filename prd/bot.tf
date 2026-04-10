# =============================================================================
# removed ブロック: AWS Chatbot / SNS (Cloudflare Notifications に完全移行)
# =============================================================================

removed {
  from = aws_iam_policy.cloudwatch_access_policy
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role_policy_attachment.cloudwatch_access_attachment
  lifecycle { destroy = false }
}

removed {
  from = awscc_chatbot_slack_channel_configuration.infra_chat_config
  lifecycle { destroy = false }
}

removed {
  from = awscc_iam_role.infra_chatbot_role
  lifecycle { destroy = false }
}

removed {
  from = aws_sns_topic.infra_chatbot_topic
  lifecycle { destroy = false }
}
