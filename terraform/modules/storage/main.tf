resource "azurerm_storage_account" "artifacts" {
  name                     = "st${var.project_name}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = true

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "code_artifacts" {
  name                  = "code-artifacts"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.artifacts.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.artifacts.primary_access_key
  sensitive = true
}

output "container_name" {
  value = azurerm_storage_container.code_artifacts.name
}
