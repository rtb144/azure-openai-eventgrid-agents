resource "azurerm_cognitive_account" "openai" {
  name                = "oai-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name
  custom_subdomain_name = "oai-${var.project_name}-${var.environment}"
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_cognitive_deployment" "models" {
  for_each = var.model_deployments

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.capacity
  }
}

output "endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "id" {
  value = azurerm_cognitive_account.openai.id
}

output "primary_access_key" {
  value     = azurerm_cognitive_account.openai.primary_access_key
  sensitive = true
}
