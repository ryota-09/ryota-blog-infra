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
