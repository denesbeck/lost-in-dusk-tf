resource "aws_lambda_function" "lostindusk_contact" {
  function_name = "LostInDuskContact"
  role          = aws_iam_role.lostindusk_contact.arn
  handler       = "PLACEHOLDER"
  runtime       = "nodejs22.x"
  filename      = "PLACEHOLDER.zip"
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_function" "lambda_layer_cleanup" {
  function_name = "LambdaLayerCleanup"
  role          = aws_iam_role.lambda_layer_cleanup.arn
  handler       = "PLACEHOLDER"
  runtime       = "nodejs22.x"
  filename      = "PLACEHOLDER.zip"
  lifecycle {
    ignore_changes = all
  }
}
