<!-- BEGIN_TF_DOCS -->

Create an Api Gateway to trigger lambda function.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.63 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#input\_lambda\_invoke\_arn) | Lambda funtion arn | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the capacity provider. | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | (Required) Name of the capacity provider. | `string` | `"webhook"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_arn"></a> [execution\_arn](#output\_execution\_arn) | The execution ARN part to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function |
| <a name="output_id"></a> [id](#output\_id) | The ID of the REST API. |
| <a name="output_root_resource_id"></a> [root\_resource\_id](#output\_root\_resource\_id) | The resource ID of the REST API's root |
<!-- END_TF_DOCS -->