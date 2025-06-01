resource "aws_cloudfront_origin_access_control" "cloudfront_origin_access_control" {
  name                              = aws_s3_bucket.s3_web.bucket_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  default_root_object = "index.html"
  tags = {
    "application" = "lostindusk"
  }
  aliases      = ["lostindusk.com"]
  http_version = "http2and3"
  price_class  = "PriceClass_100"

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  origin {
    domain_name              = aws_s3_bucket.s3_web.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.s3_web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_origin_access_control.id
  }

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3_web.bucket_regional_domain_name
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
  }

  enabled = true

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.acm_certificate.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
