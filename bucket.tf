resource "aws_s3_bucket" "bucket_resource" {
  bucket = var.bucket_name
  force_destroy = true
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    Name        = var.bucket_name
    Environment = "Prod"
  }
}