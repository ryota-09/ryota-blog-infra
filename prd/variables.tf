variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "repo_name" {
  type        = string
  description = "The name of the repository."
}

variable "domain_name" {
  type        = string
  description = "The domain name of the service."
}

variable "env_name" {
  type        = string
  description = "The deployment environment (e.g., stg, prd)."
}

variable "story_record_name" {
  type        = string
  description = "The name of the Storybook DNS record."
  default     = "storybook"
}

variable "story_record_value" {
  type        = string
  description = "The value of the Storybook DNS record."
  default     = ""
}

# --- Cloudflare ---
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}
