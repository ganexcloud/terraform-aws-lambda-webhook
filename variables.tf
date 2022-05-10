variable "name" {
  description = "(Required) Name of the capacity provider."
  type        = string
}

variable "resource_name" {
  description = "(Required) Name of the capacity provider."
  type        = string
  default     = "webhook"
}

variable "lambda_invoke_arn" {
  description = "Lambda funtion arn"
  type        = string
}
