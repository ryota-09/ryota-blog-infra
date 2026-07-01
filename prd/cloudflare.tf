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
  location   = "ENAM"
}

# --- D1 Database (タグキャッシュ用) ---
# CLIで作成済み: 1a6b58c7-84ca-4bad-84dc-b665810bf3aa
# terraform import cloudflare_d1_database.tags 942aee8d0edafe01b14d554c3ea7807f/1a6b58c7-84ca-4bad-84dc-b665810bf3aa
resource "cloudflare_d1_database" "tags" {
  account_id = var.cloudflare_account_id
  name       = "${var.repo_name}-tags-${var.env_name}"
}

# --- Workers Custom Domain ---
# DNS レコードと SSL 証明書を自動管理する
resource "cloudflare_workers_domain" "main" {
  account_id  = var.cloudflare_account_id
  zone_id     = cloudflare_zone.main.id
  hostname    = var.domain_name
  service     = "${var.repo_name}-${var.env_name}"
  environment = "production"
}

# --- Storybook (Cloudflare Pages) ---
resource "cloudflare_pages_project" "storybook" {
  account_id        = var.cloudflare_account_id
  name              = "${var.repo_name}-storybook"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = var.repo_org
      repo_name                     = var.repo_name
      production_branch             = "main"
      production_deployment_enabled = true
      pr_comments_enabled           = true
      preview_deployment_setting    = "custom"
      preview_branch_includes       = ["develop"]
    }
  }

  build_config {
    build_command   = "npm run build-storybook"
    destination_dir = "storybook-static"
  }
}

resource "cloudflare_pages_domain" "storybook" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.storybook.name
  domain       = "story.${var.domain_name}"
}

resource "cloudflare_record" "storybook" {
  zone_id = cloudflare_zone.main.id
  name    = "story"
  type    = "CNAME"
  value   = cloudflare_pages_project.storybook.subdomain
  proxied = true
  ttl     = 1
}
