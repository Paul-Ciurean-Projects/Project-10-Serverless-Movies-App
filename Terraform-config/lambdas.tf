#############################
# upload-lambda-to-dynamodb #
#############################

resource "aws_iam_role" "lambda_execution_role" {
  name = "upload-lambda-to-dynamodb-lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.upload_bucket.arn}/*",
          "arn:aws:sns:${var.region}:${var.aws_account_id}:${var.sns}"
        ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_upload_from_s3" {
  function_name = "upload-lambda-to-dynamodb"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "upload-lambda-to-dynamodb.lambda_handler"
  runtime       = "python3.12"

  filename         = "upload-lambda-to-dynamodb.zip"
  source_code_hash = filebase64sha256("upload-lambda-to-dynamodb.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.movies_table.name,
      SNS_TOPIC_ARN = aws_sns_topic.update_dynamodb.arn
    }
  }
}

resource "aws_cloudwatch_log_group" "upload_lambda_log_group" {
  name              = "/aws/lambda/upload-lambda-to-dynamodb"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_upload_from_s3.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

# Create an SNS Topic 

resource "aws_sns_topic" "update_dynamodb" {
  name = var.sns
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.update_dynamodb.arn
  protocol  = "email"
  endpoint  = var.sns_email
}


#################
# search-lambda #
#################

resource "aws_iam_role" "lambda_execution_role_2" {
  name = "api_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy_api" {
  name = "lambda_policy_api"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:logs:${var.region}:${var.aws_account_id}:*",
        "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/search_lambda_api:*"

      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment_2" {
  role       = aws_iam_role.lambda_execution_role_2.name
  policy_arn = aws_iam_policy.lambda_policy_api.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment_3" {
  role       = aws_iam_role.lambda_execution_role_2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment_4" {
  role       = aws_iam_role.lambda_execution_role_2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_lambda_function" "search_lambda_api" {
  function_name = "search_lambda_api"
  role          = aws_iam_role.lambda_execution_role_2.arn
  handler       = "search-lambda.lambda_handler"
  runtime       = "python3.12"
  filename         = "search-lambda.zip"
  source_code_hash = filebase64sha256("search-lambda.zip")
}

resource "aws_cloudwatch_log_group" "search_lambda_log_groups" {
  name              = "/aws/lambda/search_lambda_api"
  retention_in_days = 14
}

# Lambda integration with API

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_lambda_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.search_api.execution_arn}/*/*"

  depends_on = [
    aws_api_gateway_integration_response.search_api
  ]
}


#################
# upload-lambda #
#################

resource "aws_lambda_function" "update_lambda_api" {
  function_name = "update_lambda_api"
  role          = aws_iam_role.lambda_execution_role_2.arn
  handler       = "update-lambda.lambda_handler"
  runtime       = "python3.12"
  filename         = "update-lambda.zip"
  source_code_hash = filebase64sha256("update-lambda.zip")
}

resource "aws_cloudwatch_log_group" "update_lambda_log_groups" {
  name              = "/aws/lambda/update_lambda_api"
  retention_in_days = 14
}

# Lambda integration with API

resource "aws_lambda_permission" "api_gateway_invoke_2" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_lambda_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.update_api.execution_arn}/*/*"

  depends_on = [
    aws_api_gateway_integration_response.update_api
  ]
}