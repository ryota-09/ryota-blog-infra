resource "aws_ecr_repository" "ryota_blog" {
  name = local.repo_name
}

resource "aws_ecr_lifecycle_policy" "ryota_blog" {
  repository = aws_ecr_repository.ryota_blog.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 10,
      "description": "Expire images count more than 15",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 15
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
  EOF
}
