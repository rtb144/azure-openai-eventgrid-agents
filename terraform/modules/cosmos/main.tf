resource "azurerm_cosmosdb_account" "state" {
  name                = "cosmos-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "workflows" {
  name                = "workflows"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.state.name
}

resource "azurerm_cosmosdb_sql_container" "tasks" {
  name                = "tasks"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.state.name
  database_name       = azurerm_cosmosdb_sql_database.workflows.name
  partition_key_paths = ["/taskId"]

  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
  }
}

output "endpoint" {
  value = azurerm_cosmosdb_account.state.endpoint
}

output "primary_key" {
  value     = azurerm_cosmosdb_account.state.primary_key
  sensitive = true
}

output "database_name" {
  value = azurerm_cosmosdb_sql_database.workflows.name
}

output "container_name" {
  value = azurerm_cosmosdb_sql_container.tasks.name
}
