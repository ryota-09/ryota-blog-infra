# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform infrastructure repository for managing AWS resources for the Ryota Blog application. The infrastructure supports both staging and production environments with separate state management.

## Commands

### Staging Environment
```bash
cd stg
terraform init
terraform plan -var-file=stg.tfvars
terraform apply -var-file=stg.tfvars
terraform destroy -var-file=stg.tfvars  # when needed
```

### Production Environment
```bash
cd prd
terraform init
terraform plan -var-file=prd.tfvars
terraform apply -var-file=prd.tfvars
terraform destroy -var-file=prd.tfvars  # when needed
```

### Format and Validation
```bash
terraform fmt -recursive
terraform validate
```

## Architecture

The infrastructure manages a containerized Next.js blog application with the following key components:

- **AWS App Runner**: Hosts the containerized Next.js application
- **Amazon ECR**: Stores Docker container images
- **Route 53**: DNS management and domain routing
- **ACM**: SSL/TLS certificate management
- **AWS WAF**: Web application security protection
- **CloudWatch**: Logging and monitoring

## Environment Structure

- **Staging (`stg/`)**: Development environment with ECR repository and GitHub Actions integration for CI/CD
- **Production (`prd/`)**: Live environment with full App Runner service, custom domain, and certificate management

The staging environment has most resources commented out and focuses on ECR management, while production runs the full application stack.

## State Management

- **Staging**: S3 bucket `tf-state-ryota-blog-stg` in `ap-northeast-1`
- **Production**: S3 bucket `tf-state-ryota-blog-prd` in `ap-northeast-1`

Each environment maintains separate Terraform state files to prevent conflicts between deployments.

## Variable Configuration

Both environments use `.tfvars` files for environment-specific configuration. Key variables include:
- MicroCMS API integration settings
- Google Analytics and Tag Manager IDs
- Domain and DNS configuration
- GitHub repository settings for OIDC
- RUM monitoring configuration