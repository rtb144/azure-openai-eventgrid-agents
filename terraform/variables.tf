variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg-aoai-agents"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project short name used for resource naming"
  default     = "aoaiagents"
}

variable "openai_sku" {
  type        = string
  description = "SKU for Azure OpenAI account"
  default     = "S0"
}

variable "openai_model_deployments" {
  type = map(object({
    model_name    = string
    model_version = string
    sku_name      = string
    capacity      = optional(number, 10)
  }))
  description = "Azure OpenAI model deployments"
  default = {
    gpt4o = {
      model_name    = "gpt-4o"
      model_version = "2024-11-20"
      sku_name      = "Standard"
      capacity      = 10
    }
    gpt4o-mini = {
      model_name    = "gpt-4o-mini"
      model_version = "2024-07-18"
      sku_name      = "Standard"
      capacity      = 20
    }
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    project     = "aoai-coding-review-agents"
    managed_by  = "terraform"
    environment = "dev"
  }
}
