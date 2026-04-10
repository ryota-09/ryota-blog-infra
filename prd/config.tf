provider "aws" {
  region  = var.aws_region
  profile = "terraform"
  default_tags {
    tags = {
      Terraform   = var.repo_name
      Environment = terraform.workspace
    }
  }
}

# ACM 証明書 (us-east-1) の removed ブロック処理に必要
# 全 removed ブロックの処理完了後に削除可能
provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "terraform"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
