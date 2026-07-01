output "CLOUDFLARE_ZONE_ID" {
  description = "Cloudflare Zone ID"
  value       = cloudflare_zone.main.id
}

output "CLOUDFLARE_ZONE_NS" {
  description = "Cloudflare Zone nameservers"
  value       = cloudflare_zone.main.name_servers
}

output "R2_BUCKET_NAME" {
  description = "R2 bucket name for ISR cache"
  value       = cloudflare_r2_bucket.cache.name
}

output "D1_DATABASE_ID" {
  description = "D1 database ID (wrangler.jsonc の database_id に設定する)"
  value       = cloudflare_d1_database.tags.id
}
