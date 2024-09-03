data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases      = ["lostindusk.com"]
  http_version = "http2and3"
  price_class  = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.s3_web_website_configuration.website_endpoint
    origin_id   = aws_s3_bucket.s3_web.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

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
