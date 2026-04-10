# =============================================================================
# removed ブロック: WAF (Cloudflare 組み込み DDoS/WAF に置換)
# =============================================================================

removed {
  from = aws_wafv2_web_acl.frontend_acl
  lifecycle { destroy = false }
}

removed {
  from = aws_wafv2_web_acl_association.frontend_acl_association
  lifecycle { destroy = false }
}
