resource "aws_s3_bucket" "s3_web" {
  bucket              = "lostindusk.com"
  object_lock_enabled = false

  tags = {
    "application" = "lostindusk"
  }
}

resource "aws_s3_bucket" "s3_lambda_functions" {
  bucket = "lambda-functions-5d47b429"

  tags = {
    "application" = "lostindusk"
  }
}

resource "aws_s3_bucket" "s3_lambda_layers" {
  bucket = "lambda-layers-fb0156a1"

  tags = {
    "application" = "lostindusk"
  }
}

resource "aws_s3_bucket" "s3_lambda_hashes" {
  bucket = "lambda-hashes-ac780253"

  tags = {
    "application" = "lostindusk"
  }
}

resource "aws_s3_bucket_versioning" "s3_web_versioning" {
  bucket = aws_s3_bucket.s3_web.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_web_public_access_block" {
  bucket = aws_s3_bucket.s3_web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_web_ownership_controls" {
  bucket = aws_s3_bucket.s3_web.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "s3_web_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_web_ownership_controls]

  bucket = aws_s3_bucket.s3_web.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3_web_policy" {
  bucket = aws_s3_bucket.s3_web.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}
