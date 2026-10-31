# Deployment & Operations

## Deployment Order

1. Apply Terraform (`terraform apply`)
2. Deploy Function App code (zip deploy, GitHub Actions, or Azure DevOps)
3. Create Event Grid subscriptions (or use Function Event Grid triggers which auto-create them)
4. Smoke-test with a sample `TaskSubmitted` event
5. Configure alerts on Application Insights

## Sample Event Grid Subscription (CLI)

```bash
az eventgrid event-subscription create \
  --name reviewer-sub \
  --source-resource-id <eventgrid-topic-id> \
  --endpoint-type azurefunction \
  --endpoint <function-resource-id> \
  --included-event-types com.contoso.coding.CodeGenerated
```

## Observability

- Application Insights captures Function executions and OpenTelemetry traces (when Agent Framework or OpenTelemetry SDK is added)
- Key custom metrics to track:
  - Tasks started / completed
  - Average iterations per task
  - Token usage per agent
  - Event delivery failures (Event Grid metrics)

## Operational Concerns

| Concern | Recommendation |
|---------|----------------|
| Infinite loops | Enforce `maxIterations` in both agents and Cosmos |
| Poison events | Configure Event Grid dead-letter destination |
| Cost | Set token budgets; use gpt-4o-mini for simple reviews |
| Security | Private endpoints, Content Safety, managed identity only |
| Idempotency | Check Cosmos before processing; store processed event IDs |

## Human-in-the-Loop

Optional approval step: publish a `HumanApprovalRequired` event and pause until an external system (Logic Apps, custom API) publishes `HumanApproved` or `HumanRejected`.

## Extensibility

- Add a Tester Agent that consumes `CodeGenerated` and runs unit tests in a sandbox
- Replace Functions with Foundry Hosted Agents or Container Apps for richer tool use
- Mirror key events to Event Hubs for long-term audit/replay
