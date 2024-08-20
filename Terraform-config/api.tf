##############
# API Search #
##############

resource "aws_api_gateway_rest_api" "search_api" {
  name = "search_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "search_api" {
  parent_id   = aws_api_gateway_rest_api.search_api.root_resource_id
  path_part   = "search_api"
  rest_api_id = aws_api_gateway_rest_api.search_api.id
}

resource "aws_api_gateway_method" "search_api" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.search_api.id
  rest_api_id   = aws_api_gateway_rest_api.search_api.id
}

resource "aws_api_gateway_method_response" "search_api" {
  rest_api_id = aws_api_gateway_rest_api.search_api.id
  resource_id = aws_api_gateway_resource.search_api.id
  http_method = aws_api_gateway_method.search_api.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}

resource "aws_api_gateway_integration" "search_api" {
  http_method             = aws_api_gateway_method.search_api.http_method
  resource_id             = aws_api_gateway_resource.search_api.id
  rest_api_id             = aws_api_gateway_rest_api.search_api.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.search_lambda_api.invoke_arn
}

resource "aws_api_gateway_integration_response" "search_api" {
  rest_api_id = aws_api_gateway_rest_api.search_api.id
  resource_id = aws_api_gateway_resource.search_api.id
  http_method = aws_api_gateway_method.search_api.http_method
  status_code = aws_api_gateway_method_response.search_api.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.search_api
  ]
}

resource "aws_api_gateway_deployment" "search_api" {
  rest_api_id = aws_api_gateway_rest_api.search_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.search_api.id,
      aws_api_gateway_method.search_api.id,
      aws_api_gateway_method_response.search_api.id,
      aws_api_gateway_integration.search_api.id,
      aws_api_gateway_integration_response.search_api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "search_api" {
  deployment_id = aws_api_gateway_deployment.search_api.id
  rest_api_id   = aws_api_gateway_rest_api.search_api.id
  stage_name    = "search_api"
}

# OPTIONS METHOD

resource "aws_api_gateway_method" "search_api_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.search_api.id
  rest_api_id   = aws_api_gateway_rest_api.search_api.id
}

resource "aws_api_gateway_method_response" "search_api_options" {
  rest_api_id = aws_api_gateway_rest_api.search_api.id
  resource_id = aws_api_gateway_resource.search_api.id
  http_method = aws_api_gateway_method.search_api_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}

resource "aws_api_gateway_integration" "search_api_options" {
  http_method = aws_api_gateway_method.search_api_options.http_method
  resource_id = aws_api_gateway_resource.search_api.id
  rest_api_id = aws_api_gateway_rest_api.search_api.id
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "search_api_options" {
  http_method = aws_api_gateway_method.search_api_options.http_method
  rest_api_id = aws_api_gateway_rest_api.search_api.id
  resource_id = aws_api_gateway_resource.search_api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.search_api_options
  ]
}


##############
# Update API #
##############


resource "aws_api_gateway_rest_api" "update_api" {
  name = "update_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "update_api" {
  parent_id   = aws_api_gateway_rest_api.update_api.root_resource_id
  path_part   = "update_api"
  rest_api_id = aws_api_gateway_rest_api.update_api.id
}

resource "aws_api_gateway_method" "update_api" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.update_api.id
  rest_api_id   = aws_api_gateway_rest_api.update_api.id
}

resource "aws_api_gateway_method_response" "update_api" {
  rest_api_id = aws_api_gateway_rest_api.update_api.id
  resource_id = aws_api_gateway_resource.update_api.id
  http_method = aws_api_gateway_method.update_api.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}

resource "aws_api_gateway_integration" "update_api" {
  http_method             = aws_api_gateway_method.update_api.http_method
  resource_id             = aws_api_gateway_resource.update_api.id
  rest_api_id             = aws_api_gateway_rest_api.update_api.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_lambda_api.invoke_arn
}

resource "aws_api_gateway_integration_response" "update_api" {
  rest_api_id = aws_api_gateway_rest_api.update_api.id
  resource_id = aws_api_gateway_resource.update_api.id
  http_method = aws_api_gateway_method.update_api.http_method
  status_code = aws_api_gateway_method_response.update_api.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.update_api
  ]
}

resource "aws_api_gateway_deployment" "update_api" {
  rest_api_id = aws_api_gateway_rest_api.update_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.update_api.id,
      aws_api_gateway_method.update_api.id,
      aws_api_gateway_method_response.update_api.id,
      aws_api_gateway_integration.update_api.id,
      aws_api_gateway_integration_response.update_api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "update_api" {
  deployment_id = aws_api_gateway_deployment.update_api.id
  rest_api_id   = aws_api_gateway_rest_api.update_api.id
  stage_name    = "update_api"
}

# OPTIONS METHOD

resource "aws_api_gateway_method" "update_api_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.update_api.id
  rest_api_id   = aws_api_gateway_rest_api.update_api.id
}

resource "aws_api_gateway_method_response" "update_api_options" {
  rest_api_id = aws_api_gateway_rest_api.update_api.id
  resource_id = aws_api_gateway_resource.update_api.id
  http_method = aws_api_gateway_method.update_api_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}

resource "aws_api_gateway_integration" "update_api_options" {
  http_method = aws_api_gateway_method.update_api_options.http_method
  resource_id = aws_api_gateway_resource.update_api.id
  rest_api_id = aws_api_gateway_rest_api.update_api.id
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "update_api_options" {
  http_method = aws_api_gateway_method.update_api_options.http_method
  rest_api_id = aws_api_gateway_rest_api.update_api.id
  resource_id = aws_api_gateway_resource.update_api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.update_api_options
  ]
}

output "update_api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.update_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.update_api.stage_name}/${aws_api_gateway_resource.update_api.path_part}"
}

output "search_api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.search_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.search_api.stage_name}/${aws_api_gateway_resource.search_api.path_part}"
}