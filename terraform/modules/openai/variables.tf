variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "sku_name" { type = string }
variable "model_deployments" {
  type = map(object({
    model_name    = string
    model_version = string
    sku_name      = string
    capacity      = optional(number, 10)
  }))
}
variable "tags" { type = map(string) }
