locals {
  allowed_headers = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  allowed_methods = "'OPTIONS,POST'"
  allowed_origin  = "'https://lostindusk.com'"

  int_response_headers = {
    "method.response.header.Access-Control-Allow-Headers" = local.allowed_headers
    "method.response.header.Access-Control-Allow-Methods" = local.allowed_methods
    "method.response.header.Access-Control-Allow-Origin"  = local.allowed_origin
  }

  gw_response_headers = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = local.allowed_headers
    "gatewayresponse.header.Access-Control-Allow-Methods" = local.allowed_methods
    "gatewayresponse.header.Access-Control-Allow-Origin"  = local.allowed_origin
  }
}

resource "aws_api_gateway_rest_api" "api_gw_rest_api" {
  name = "lostindusk"

  tags = {
    application = "lostindusk"
  }
}

resource "aws_api_gateway_resource" "api_gw_resource" {
  parent_id   = aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id
  path_part   = "contact"
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
}

resource "aws_api_gateway_method" "options_method" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.api_gw_resource.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
    {"statusCode": 200}"
    EOF
  }
}

resource "aws_api_gateway_method_response" "options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id = aws_api_gateway_resource.api_gw_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id         = aws_api_gateway_resource.api_gw_resource.id
  http_method         = aws_api_gateway_method.options_method.http_method
  status_code         = aws_api_gateway_method_response.options_response_200.status_code
  response_parameters = local.int_response_headers
}

resource "aws_api_gateway_method" "post_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.api_gw_resource.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id

  request_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw_rest_api.id
  resource_id             = aws_api_gateway_resource.api_gw_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lostindusk_contact.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lostindusk_contact.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gw_rest_api.id}/*/POST/contact"
}

resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
  response_parameters = local.gw_response_headers
}

resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = local.gw_response_headers
}

resource "aws_api_gateway_stage" "v1_stage" {
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api.id
  stage_name    = "v1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api.id

  triggers = {
    redeploy_hash = sha1(jsonencode([
      aws_api_gateway_method.post_method.id,
      aws_api_gateway_integration.post_integration.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id,
      aws_api_gateway_integration_response.options_integration_response.id,
      aws_api_gateway_method_response.options_response_200.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_integration_response.options_integration_response,
    aws_api_gateway_method_response.options_response_200
  ]
}

resource "aws_api_gateway_usage_plan" "api_gw_usage_plan" {
  name = "LostInDuskContactUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gw_rest_api.id
    stage  = aws_api_gateway_stage.v1_stage.stage_name
  }

  quota_settings {
    limit  = 10
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 5
  }
}
