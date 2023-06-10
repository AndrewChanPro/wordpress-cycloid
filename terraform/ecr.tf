resource "aws_ecr_repository" "repository" {
  name                 = "cycloid_wordpress"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}