resource "aws_iam_role" "scheduler_role" {
  name = "SchedulerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })

  tags = {
    "application" = "common"
  }
}

resource "aws_iam_role_policy_attachment" "scheduler_lambda_invoke_policy" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_role" "lambda_layer_cleanup" {
  name = "LambdaLayerCleanupRole"

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
    "application" = "common"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_layer_cleanup_basic_exec_policy" {
  role       = aws_iam_role.lambda_layer_cleanup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_layer_policy" {
  name = "LambdaLayerPolicy"
  role = aws_iam_role.lambda_layer_cleanup.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "ListDeleteLambdaLayers",
        "Effect" : "Allow",
        "Action" : [
          "lambda:DeleteLayerVersion",
          "lambda:ListLayerVersions",
          "lambda:ListLayers"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "lostindusk_contact" {
  name = "LostInDuskContactRole"

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

resource "aws_iam_role_policy_attachment" "lostindusk_contact_basic_exec_policy" {
  role       = aws_iam_role.lostindusk_contact.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_parameter_store_policy" {
  name = "LambdaParameterStorePolicy"
  role = aws_iam_role.lostindusk_contact.id

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

resource "aws_iam_role_policy" "lambda_ses_send_policy" {
  name = "LambdaSESSendPolicy"
  role = aws_iam_role.lostindusk_contact.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowSESSendFromVerifiedIdentity",
        Effect   = "Allow",
        Action   = "ses:SendEmail",
        Resource = "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/*"
        Condition : {
          "StringEquals" : {
            "ses:FromAddress" : "contact@lostindusk.com"
          }
        }
      }
    ]
  })
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
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
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
