resource "aws_s3_bucket" "s3_web" {
  bucket              = "lostindusk.com"
  object_lock_enabled = false
}

resource "aws_s3_bucket_versioning" "s3_web_versioning" {
  bucket = aws_s3_bucket.s3_web.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_web_public_access_block" {
  bucket = aws_s3_bucket.s3_web.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_web_ownership_controls" {
  bucket = aws_s3_bucket.s3_web.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_web_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_web_ownership_controls]

  bucket = aws_s3_bucket.s3_web.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "s3_web_website_configuration" {
  bucket = aws_s3_bucket.s3_web.id

  index_document {
    suffix = "index.html"
  }
}
