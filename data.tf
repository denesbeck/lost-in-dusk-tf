data "aws_caller_identity" "current" {}

data "aws_lambda_function" "lambda_contact" {
  function_name = var.lambda_contact
}
