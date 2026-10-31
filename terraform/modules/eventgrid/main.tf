resource "azurerm_eventgrid_topic" "agents" {
  name                = "egt-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  input_schema        = "CloudEventSchemaV1_0"
  public_network_access_enabled = true

  tags = var.tags
}

output "endpoint" {
  value = azurerm_eventgrid_topic.agents.endpoint
}

output "id" {
  value = azurerm_eventgrid_topic.agents.id
}

output "primary_access_key" {
  value     = azurerm_eventgrid_topic.agents.primary_access_key
  sensitive = true
}
