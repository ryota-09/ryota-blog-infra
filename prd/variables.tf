variable "repo_org" {
  type        = string
  description = "GitHub organization or user name."
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
