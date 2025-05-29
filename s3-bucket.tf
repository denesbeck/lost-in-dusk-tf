resource "aws_s3_bucket" "s3_web" {
  bucket              = "lostindusk.com"
  object_lock_enabled = false

  tags = {
    "application" = "lostindusk"
  }

  tags_all = {
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

data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.s3_web.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cloudfront_distribution.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_web_policy" {
  bucket = aws_s3_bucket.s3_web.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}
