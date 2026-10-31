resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = var.tags
}

resource "azurerm_linux_function_app" "agents" {
  name                = "func-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.functions.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
    always_on = false
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_conn
    "AzureWebJobsStorage"                   = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key};EndpointSuffix=core.windows.net"
    "AOAI_ENDPOINT"                         = var.openai_endpoint
    "EVENTGRID_TOPIC_ENDPOINT"              = var.eventgrid_topic_endpoint
    "COSMOS_ENDPOINT"                       = var.cosmos_endpoint
    "COSMOS_KEY"                            = var.cosmos_primary_key
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Role assignments for the Function App managed identity
resource "azurerm_role_assignment" "openai_user" {
  scope                = var.openai_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_linux_function_app.agents.identity[0].principal_id
}

resource "azurerm_role_assignment" "eventgrid_sender" {
  scope                = var.eventgrid_topic_id
  role_definition_name = "EventGrid Data Sender"
  principal_id         = azurerm_linux_function_app.agents.identity[0].principal_id
}

output "function_app_name" {
  value = azurerm_linux_function_app.agents.name
}

output "function_app_id" {
  value = azurerm_linux_function_app.agents.id
}

output "principal_id" {
  value = azurerm_linux_function_app.agents.identity[0].principal_id
}
