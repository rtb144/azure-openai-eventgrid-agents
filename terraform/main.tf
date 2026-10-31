resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "openai" {
  source = "./modules/openai"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  sku_name            = var.openai_sku
  model_deployments   = var.openai_model_deployments
  tags                = var.tags
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
}

module "cosmos" {
  source = "./modules/cosmos"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
}

module "eventgrid" {
  source = "./modules/eventgrid"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
}

module "functions" {
  source = "./modules/functions"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  project_name                 = var.project_name
  environment                  = var.environment
  storage_account_name         = module.storage.storage_account_name
  storage_account_access_key   = module.storage.primary_access_key
  application_insights_key     = module.monitoring.instrumentation_key
  application_insights_conn    = module.monitoring.connection_string
  openai_endpoint              = module.openai.endpoint
  openai_id                    = module.openai.id
  eventgrid_topic_endpoint     = module.eventgrid.endpoint
  eventgrid_topic_id           = module.eventgrid.id
  cosmos_endpoint              = module.cosmos.endpoint
  cosmos_primary_key           = module.cosmos.primary_key
  tags                         = var.tags
}
