# Terraform Guide

The infrastructure is defined as a modular Terraform corpus under `terraform/`.

## Quick Start

```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Modules

| Module | Path | Resources Created |
|--------|------|-------------------|
| **openai** | `modules/openai` | Cognitive Account + model deployments |
| **eventgrid** | `modules/eventgrid` | Custom Topic (CloudEventSchemaV1_0) |
| **storage** | `modules/storage` | Storage Account + `code-artifacts` container |
| **cosmos** | `modules/cosmos` | Cosmos Account + `workflows` DB + `tasks` container |
| **functions** | `modules/functions` | Linux Consumption Function App + RBAC assignments |
| **monitoring** | `modules/monitoring` | Log Analytics + Application Insights |

## Key Variables

- `resource_group_name`, `location`, `environment`, `project_name`
- `openai_model_deployments` — map of model name/version/sku/capacity
- `tags`

## Outputs

- `openai_endpoint`, `eventgrid_topic_endpoint`, `storage_account_name`
- `cosmos_endpoint`, `function_app_name`
- `application_insights_connection_string` (sensitive)

## Role Assignments

The Function App managed identity receives:
- `Cognitive Services OpenAI User` on the OpenAI resource
- `EventGrid Data Sender` on the topic

Additional roles (Storage Blob Data Contributor, Cosmos DB Built-in Data Contributor) can be added as needed.

## Next Infrastructure Steps

1. Add Event Grid subscriptions pointing to the Function App (or use Event Grid trigger bindings)
2. Add Key Vault + private endpoints
3. Enable Content Safety on the OpenAI account
4. Add diagnostic settings for all resources
