/**
  *
  * Create an Api Gateway to trigger lambda function.
  */

resource "aws_api_gateway_rest_api" "this" {
  name = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_deployment.this.stage_name
  method_path = "*/*"

  settings {
    #metrics_enabled = true
    #logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = aws_api_gateway_method.root.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_invoke_arn
  request_parameters = {
    "integration.request.header.X-Amz-Invocation-Type" = "'Event'"
  }
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_method.root,
    aws_api_gateway_integration.root,
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.resource_name
}

#
#resource "aws_api_gateway_domain_name" "this" {
#  domain_name     = var.hostname
#  certificate_arn = module.certificate.arn
#}

#resource "aws_api_gateway_base_path_mapping" "this" {
#  api_id      = aws_api_gateway_rest_api.this.id
#  stage_name  = aws_api_gateway_deployment.this.stage_name
#  domain_name = aws_api_gateway_domain_name.this.domain_name
#}
#

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = "POST"
  status_code = "202"
  depends_on = [
    aws_api_gateway_deployment.this
  ]
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = "POST"
  status_code = "202"
  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{"message":"Deploy started"}
EOF
  }
  depends_on = [
    aws_api_gateway_deployment.this,
    aws_api_gateway_method_response.this
  ]
}
