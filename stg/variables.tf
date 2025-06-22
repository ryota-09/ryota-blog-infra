variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "repo_org" {
  type        = string
  description = "GitHub organization name"
}

variable "repo_name" {
  type        = string
  description = "The name of the repository."
}

variable "env_name" {
  type        = string
  description = "The deployment environment (e.g., stg, prd)."
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "base_url" {
  type        = string
  description = "The base URL of the service."
}

variable "microcms_service_domain" {
  type        = string
  description = "microcms service domain."
}

variable "microcms_api_key" {
  type        = string
  description = "microcms api key."
}

variable "domain_name" {
  type        = string
  description = "The domain name of the service."
}

variable "cert_validation_record_name_a" {
  type        = string
  description = "The name of the DNS record for certificate validation."
}

variable "cert_validation_record_value_a" {
  type        = string
  description = "The value of the DNS record for certificate validation."
}

variable "cert_validation_record_name_b" {
  type        = string
  description = "The name of the DNS record for certificate validation."
}

variable "cert_validation_record_value_b" {
  type        = string
  description = "The value of the DNS record for certificate validation."
}

variable "cert_validation_record_name_c" {
  type        = string
  description = "The name of the DNS record for certificate validation."
}

variable "cert_validation_record_value_c" {
  type        = string
  description = "The value of the DNS record for certificate validation."
}

variable "dns_record_name" {
  type        = string
  description = "The name of the DNS record."
}

variable "dns_record_value" {
  type        = string
  description = "The value of the DNS record."
}

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel."
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace."
}

variable "gtm_id" {
  type        = string
  description = "Google Tag Manager ID."
}

variable "ga_id" {
  type        = string
  description = "Google Analytics ID."
}

variable "guest_role_arn" {
  type        = string
  description = "The ARN of the guest role."
}

variable "identity_pool_id" {
  type        = string
  description = "The ID of the identity pool."
}

variable "application_id" {
  type        = string
  description = "The ID of the application."
}

variable "cloudfront_secret_header_value" {
  type        = string
  description = "Secret header value for CloudFront to App Runner communication."
  sensitive   = true
}