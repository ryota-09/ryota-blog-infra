# =============================================================================
# removed ブロック: CloudWatch / RUM / Cognito / IAM
# (GA/GTM のみで継続、AWS RUM は廃止)
# =============================================================================

# --- CloudWatch Alarms ---
removed {
  from = aws_cloudwatch_metric_alarm.frontend_4xx_alarm
  lifecycle { destroy = false }
}

removed {
  from = aws_cloudwatch_metric_alarm.frontend_5xx_alarm
  lifecycle { destroy = false }
}

removed {
  from = aws_cloudwatch_metric_alarm.first_input_delay_alarm
  lifecycle { destroy = false }
}

# --- RUM ---
removed {
  from = aws_rum_app_monitor.frontend_rum
  lifecycle { destroy = false }
}

# --- Cognito ---
removed {
  from = aws_cognito_identity_pool.id_pool
  lifecycle { destroy = false }
}

removed {
  from = aws_cognito_identity_pool_roles_attachment.guest_attachment
  lifecycle { destroy = false }
}

# --- IAM (RUM Guest Role) ---
removed {
  from = aws_iam_policy.guest_policy
  lifecycle { destroy = false }
}

removed {
  from = aws_iam_role.guest_role
  lifecycle { destroy = false }
}
