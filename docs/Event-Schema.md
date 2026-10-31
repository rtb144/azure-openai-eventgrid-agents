# Event Schema

All coordination uses **CloudEvents v1.0** on an Azure Event Grid Custom Topic (`input_schema = CloudEventSchemaV1_0`).

## Event Types

| Type | Publisher | Subscriber(s) | Purpose |
|------|-----------|---------------|---------|
| `com.contoso.coding.TaskSubmitted` | External / API | Coder Agent | Start a new coding task |
| `com.contoso.coding.CodeGenerated` | Coder Agent | Reviewer Agent | Code ready for review |
| `com.contoso.coding.ReviewCompleted` | Reviewer Agent | Coder / Orchestrator | Review finished (approved) |
| `com.contoso.coding.ChangesRequested` | Reviewer Agent | Coder Agent | Iteration required |
| `com.contoso.coding.WorkflowCompleted` | Either | Downstream | Terminal success or failure |

## Common Fields

Every event includes:

- `specversion`: `"1.0"`
- `type`: one of the types above
- `source`: `/agents/coder` or `/agents/reviewer` or `/api`
- `subject`: the `taskId` (used for filtering)
- `id`: unique event ID
- `time`: RFC 3339 timestamp
- `datacontenttype`: `"application/json"`

## Data Payload Examples

### TaskSubmitted
```json
{
  "taskId": "task-12345",
  "iteration": 0,
  "requirements": "Implement a Python function that validates email addresses",
  "language": "python",
  "maxIterations": 3,
  "correlationId": "corr-abc"
}
```

### CodeGenerated
```json
{
  "taskId": "task-12345",
  "iteration": 1,
  "blobUri": "https://st....blob.core.windows.net/code-artifacts/task-12345/v1.zip",
  "language": "python",
  "summary": "Created email_validator.py with regex and unit tests"
}
```

### ReviewCompleted / ChangesRequested
```json
{
  "taskId": "task-12345",
  "iteration": 1,
  "status": "changes_requested",
  "summary": "Missing edge-case handling for internationalized domains",
  "findings": [
    {
      "severity": "major",
      "file": "email_validator.py",
      "line": 42,
      "title": "Incomplete IDN support",
      "details": "Current regex does not handle punycode",
      "suggestion": "Use the idna library"
    }
  ]
}
```

## Filtering

Event Grid subscriptions filter on:
- `eventType` (e.g. only `CodeGenerated` for the Reviewer)
- `subjectBeginsWith` = task prefix if needed

## Idempotency Key

Handlers should treat `(taskId, iteration, eventType)` as the idempotency key and store processed event IDs in Cosmos DB.
