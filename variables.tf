variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS Region"
}

variable "ssm_kms_key_id" {
  type        = string
  default     = "a27b309f-d9df-4fd0-a3ad-60afb50eab73"
  description = "SSM KMS Key Id"
}

variable "lambda_functions_repo" {
  type        = string
  default     = "denesbeck/lambda-functions"
  description = "GitHub repository for the Lambda functions in the format `owner/repo`"
}

variable "timezone" {
  type        = string
  default     = "Europe/Berlin"
  description = "Timezone"
}
