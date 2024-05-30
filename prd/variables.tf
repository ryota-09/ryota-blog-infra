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

variable "base_url" {
  type        = string
  description = "The base URL of the service."
}

variable "apprunner_role_arn" {
  type        = string
  description = "The name of the AppRunner role."
}

variable "image_uri" {
  type = string
  description = "value of the image uri"
}

variable "image_tag" {
  type    = string
  default = "latest" 
}

variable "microcms_service_domain" {
  type        = string
  description = "microcms service domain."
}

variable "microcms_api_key" {
  type        = string
  description = "microcms api key."
}

variable "gtm_id" {
  type        = string
  description = "Google Tag Manager ID."
}

variable "ga_id" {
  type        = string
  description = "Google Analytics ID."
}