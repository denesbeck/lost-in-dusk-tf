resource "aws_scheduler_schedule" "lambda_layer_cleanup" {
  name        = "LambdaLayerCleanup"
  description = "Delete old versions of Lambda Layers"
  group_name  = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression_timezone = var.timezone
  schedule_expression          = "cron(0 0 1 * ? *)"

  target {
    arn      = aws_lambda_function.lambda_layer_cleanup.arn
    role_arn = aws_iam_role.scheduler_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 1800
      maximum_retry_attempts       = 3
    }
  }
}
