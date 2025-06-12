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
        Sid : "AllowKmsAndSsmAccess",
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

resource "aws_iam_role_policy_attachment" "lambda_basic_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_parameter_store_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_parameter_store_policy.arn
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.lambda_functions_repo}:ref:refs/heads/*"
        },
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_deploy_policy" {
  name = "LambdaDeployPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowS3Access",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.s3_lambda_functions.arn,
          "${aws_s3_bucket.s3_lambda_functions.arn}/*",
          aws_s3_bucket.s3_lambda_layers.arn,
          "${aws_s3_bucket.s3_lambda_layers.arn}/*",
          aws_s3_bucket.s3_lambda_hashes.arn,
          "${aws_s3_bucket.s3_lambda_hashes.arn}/*",

        ]
      },
      {
        Sid    = "AllowLambdaManagement",
        Effect = "Allow",
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:UpdateAlias",
          "lambda:GetFunction",
          "lambda:PublishLayerVersion",
          "lambda:GetFunctionConfiguration"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lost-in-dusk-contact-lambda"
      },
      {
        "Effect" : "Allow",
        "Action" : "lambda:GetLayerVersion",
        "Resource" : "arn:aws:lambda:eu-central-1:${data.aws_caller_identity.current.account_id}:layer:*"
      },
      {
        Sid      = "AllowSTSAccess",
        Effect   = "Allow",
        Action   = "sts:GetCallerIdentity",
        Resource = "*"
      }
    ]
  })
}
