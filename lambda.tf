resource "aws_lambda_function" "lostindusk_contact" {
  function_name = "LostInDuskContact"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "function.zip"
  lifecycle {
    ignore_changes = [filename]
  }
}
