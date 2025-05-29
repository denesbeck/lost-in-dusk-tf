resource "aws_iam_role" "lambda_exec_role" {
  name = "lost-in-dusk-contact-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    "application" = "lostindusk"
  }
}

resource "aws_iam_policy" "lambda_parameter_store_policy" {
  name = "LambdaParameterStorePolicy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "1234567890",
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "ssm:GetParameters"
        ],
        Resource : [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:*",
          "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${var.ssm_kms_key_id}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_parameter_store_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_parameter_store_policy.arn
}
