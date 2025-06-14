resource "aws_lambda_function" "lostindusk_contact" {
  function_name = "LostInDuskContact"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "PLACEHOLDER"
  runtime       = "nodejs22.x"
  filename      = "PLACEHOLDER.zip"
  lifecycle {
    ignore_changes = all
  }
}

import {
  to = aws_lambda_function.lostindusk_contact
  id = "LostInDuskContact"
}
