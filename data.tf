data "aws_caller_identity" "current" {}

data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_lambda_function" "lambda_contact" {
  function_name = var.lambda_contact
}
