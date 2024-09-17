resource "aws_s3_bucket" "org_data_bucket" {
  bucket        = "${var.workshop_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "org_data_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.org_data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "org_data_bucket_sse" {
  bucket = aws_s3_bucket.org_data_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}