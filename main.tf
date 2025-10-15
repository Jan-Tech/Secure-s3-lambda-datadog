provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket_prefix = "secure-s3-lambda-"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_function" "s3_logger" {
  filename      = "lambda_function.zip"
  function_name = "s3_logger"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      DD_API_KEY = var.datadog_api_key
      DD_SITE    = "datadoghq.com"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.secure_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_logger.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

output "bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}