output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "openai_endpoint" {
  value     = module.openai.endpoint
  sensitive = true
}

output "openai_id" {
  value = module.openai.id
}

output "eventgrid_topic_endpoint" {
  value = module.eventgrid.endpoint
}

output "eventgrid_topic_id" {
  value = module.eventgrid.id
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "cosmos_endpoint" {
  value = module.cosmos.endpoint
}

output "function_app_name" {
  value = module.functions.function_app_name
}

output "application_insights_connection_string" {
  value     = module.monitoring.connection_string
  sensitive = true
}
