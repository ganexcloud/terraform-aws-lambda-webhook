output "id" {
  value       = aws_api_gateway_rest_api.this.arn
  description = "The ID of the REST API."
}

output "root_resource_id" {
  value       = aws_api_gateway_rest_api.this.root_resource_id
  description = "The resource ID of the REST API's root"
}

output "execution_arn" {
  value       = aws_api_gateway_rest_api.this.execution_arn
  description = "The execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}
