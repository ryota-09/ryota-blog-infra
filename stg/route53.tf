provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_route53_zone" "main" {
  provider = aws.virginia
  name     = local.domain_name
}