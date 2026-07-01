terraform {
  backend "s3" {
    bucket = "tf-state-ryota-blog-prd"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.7.0"
}
