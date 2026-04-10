# =============================================================================
# Cloudflare リソース (Production)
# =============================================================================

# --- Zone ---
resource "cloudflare_zone" "main" {
  account_id = var.cloudflare_account_id
  zone       = var.domain_name
  plan       = "free"
  type       = "full"
}

# --- R2 Bucket (ISR/インクリメンタルキャッシュ用) ---
resource "cloudflare_r2_bucket" "cache" {
  account_id = var.cloudflare_account_id
  name       = "${var.repo_name}-cache-${var.env_name}"
  location   = "APAC"
}

# --- D1 Database (タグキャッシュ用) ---
resource "cloudflare_d1_database" "tags" {
  account_id = var.cloudflare_account_id
  name       = "${var.repo_name}-tags-${var.env_name}"
}

# --- Workers Custom Domain ---
# DNS レコードと SSL 証明書を自動管理する
resource "cloudflare_workers_custom_domain" "main" {
  account_id  = var.cloudflare_account_id
  zone_id     = cloudflare_zone.main.id
  hostname    = var.domain_name
  service     = "${var.repo_name}-${var.env_name}"
  environment = "production"
}

# --- Storybook サブドメイン ---
resource "cloudflare_record" "storybook" {
  count   = var.story_record_value != "" ? 1 : 0
  zone_id = cloudflare_zone.main.id
  name    = var.story_record_name
  type    = "CNAME"
  value   = var.story_record_value
  proxied = false
  ttl     = 300
}
