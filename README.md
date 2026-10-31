# Azure OpenAI Coding & Review Agents with Event Grid

Private repository containing the architecture plan and Terraform corpus for running coding and review LLM agents on Azure OpenAI that coordinate via Azure Event Grid.

## Architecture Overview

- **Azure OpenAI**: Model deployments for coding and review
- **Event Grid Custom Topic** (CloudEvents schema): Agent coordination bus
- **Azure Functions** (Python): Host for Coder and Reviewer agents (Event Grid triggers)
- **Blob Storage**: Code artifacts and diffs
- **Cosmos DB**: Workflow state, iterations, and correlation
- **Application Insights + Log Analytics**: Observability
- **Managed Identity + RBAC**: Secure access

Agents communicate by publishing/consuming CloudEvents:
- `com.contoso.coding.TaskSubmitted`
- `com.contoso.coding.CodeGenerated`
- `com.contoso.coding.ReviewCompleted`
- `com.contoso.coding.ChangesRequested`

## Terraform Usage

```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Modules

- `modules/openai` — Cognitive Account + model deployments
- `modules/eventgrid` — Custom topic (CloudEventSchemaV1_0)
- `modules/storage` — Storage account + code-artifacts container
- `modules/cosmos` — Account + workflows database + tasks container
- `modules/functions` — Consumption plan Function App with app settings and role assignments
- `modules/monitoring` — Log Analytics + Application Insights

## Next Steps

1. Deploy the infrastructure
2. Implement the Python Function agents (Coder / Reviewer) that react to Event Grid events and call Azure OpenAI
3. Add Event Grid subscriptions pointing to the Function App
4. Optionally extend with Foundry Hosted Agents or Container Apps for richer tool use
5. Add Key Vault, Private Endpoints, and Content Safety in later iterations

## Event Schema Example

```json
{
  "specversion": "1.0",
  "type": "com.contoso.coding.CodeGenerated",
  "source": "/agents/coder",
  "subject": "task-12345",
  "id": "unique-event-id",
  "time": "2026-10-31T18:00:00Z",
  "datacontenttype": "application/json",
  "data": {
    "taskId": "task-12345",
    "iteration": 1,
    "blobUri": "https://....blob.core.windows.net/code-artifacts/task-12345/v1.zip",
    "language": "python"
  }
}
```

---

Generated as a starting corpus for the event-driven AOAI coding/review agent system.
