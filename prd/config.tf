provider "aws" {
  region  = local.aws_region
  profile = "terraform"
  default_tags {
    tags = {
      Terraform   = local.repo_name
      Environment = terraform.workspace
    }
  }
}