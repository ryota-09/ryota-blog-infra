# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform infrastructure repository for managing Cloudflare and AWS resources for the Ryota Blog application. The application is a Next.js blog deployed on **Cloudflare Workers** using **OpenNext** (`@opennextjs/cloudflare`). Both staging and production environments are managed with separate Terraform state.

## Commands

### Staging Environment
```bash
cd stg
terraform init
terraform plan -var-file=stg.tfvars
terraform apply -var-file=stg.tfvars
```

### Production Environment
```bash
cd prd
terraform init
terraform plan -var-file=prd.tfvars
terraform apply -var-file=prd.tfvars
```

### Format and Validation
```bash
terraform fmt -recursive
terraform validate
```

## Architecture

The infrastructure manages a Next.js blog application deployed on Cloudflare Workers via OpenNext:

- **Cloudflare Workers**: Hosts the Next.js application (SSR/SSG/ISR via OpenNext)
- **Cloudflare R2**: Incremental cache for ISR (bound as `NEXT_INC_CACHE_R2_BUCKET`)
- **Cloudflare D1**: Tag cache for on-demand revalidation (bound as `NEXT_TAG_CACHE_D1`)
- **Cloudflare DNS**: Domain management with automatic SSL
- **Workers Custom Domain**: Routes custom domain to Workers
- **AWS Route53**: Hosted zone retained for rollback capability (NS points to Cloudflare)

Application deployment is handled by **Wrangler** via GitHub Actions (not managed by Terraform).

### Migration Status

The infrastructure was migrated from AWS App Runner + CloudFront + WAF to Cloudflare Workers. AWS resources are preserved in Terraform state via `removed` blocks with `lifecycle { destroy = false }` for rollback safety. After confirming stability, change to `destroy = true` to clean up.

## Environment Structure

- **Staging (`stg/`)**: Full Cloudflare stack (Zone, R2, D1, Workers Custom Domain)
- **Production (`prd/`)**: Full Cloudflare stack + Route53 zone for rollback

## State Management

- **Staging**: S3 bucket `tf-state-ryota-blog-stg` in `ap-northeast-1`
- **Production**: S3 bucket `tf-state-ryota-blog-prd` in `ap-northeast-1`

Each environment maintains separate Terraform state files to prevent conflicts between deployments.

## Variable Configuration

Both environments use `.tfvars` files for environment-specific configuration. Key variables include:
- Cloudflare API token and account ID
- Domain and DNS configuration
- MicroCMS API integration settings
- Google Analytics and Tag Manager IDs
- Slack channel/workspace IDs

## Providers

- **cloudflare/cloudflare** (~> 5.0): Manages Cloudflare resources (Zone, R2, D1, DNS, Workers Custom Domain)
- **hashicorp/aws** (>= 4.9.0): Manages remaining AWS resources (Route53 zone, S3 state backend)
