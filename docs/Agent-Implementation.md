# Agent Implementation

## Recommended Runtime

Azure Functions (Python 3.11) with Event Grid triggers. Each agent is a function (or set of functions) that:

1. Receives a CloudEvent
2. Loads state from Cosmos DB
3. Calls Azure OpenAI
4. Writes artifacts to Blob Storage
5. Publishes the next CloudEvent
6. Updates Cosmos DB state

## Coder Agent Responsibilities

- Consume `TaskSubmitted` or `ChangesRequested`
- Construct a prompt that includes requirements + previous review findings (if any)
- Call Azure OpenAI (optionally with code interpreter / tool use)
- Package the generated code and store it in Blob Storage
- Publish `CodeGenerated` with the blob URI
- Increment iteration counter in Cosmos

## Reviewer Agent Responsibilities

- Consume `CodeGenerated`
- Download the artifact from Blob
- Call Azure OpenAI with a structured-output schema (findings array)
- Optionally run static analysis tools
- Publish either `ReviewCompleted` (approved) or `ChangesRequested`
- Persist the review result in Cosmos

## Suggested Function Structure

```
functions/
├── coder/
│   └── function_app.py   # Event Grid trigger for TaskSubmitted / ChangesRequested
├── reviewer/
│   └── function_app.py   # Event Grid trigger for CodeGenerated
└── shared/
    ├── openai_client.py
    ├── eventgrid_publisher.py
    ├── cosmos_state.py
    └── blob_store.py
```

## Prompt Guidance

**Coder system prompt (excerpt)**  
"You are a precise coding agent. Produce complete, runnable code that satisfies the requirements. If review findings are provided, address every major and critical finding."

**Reviewer system prompt (excerpt)**  
"You are a thorough code reviewer. Return only valid JSON matching the Review schema. Focus on correctness, security, and missing tests. Do not invent issues."

## Structured Output Schema (Reviewer)

```json
{
  "type": "object",
  "properties": {
    "status": { "enum": ["approved", "changes_requested"] },
    "summary": { "type": "string" },
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "severity": { "enum": ["critical", "major", "minor"] },
          "file": { "type": "string" },
          "line": { "type": "integer" },
          "title": { "type": "string" },
          "details": { "type": "string" },
          "suggestion": { "type": "string" }
        }
      }
    }
  },
  "required": ["status", "summary"]
}
```

## Iteration Control

Store in Cosmos:

```json
{
  "id": "task-12345",
  "taskId": "task-12345",
  "iteration": 2,
  "maxIterations": 3,
  "status": "reviewing",
  "lastEventId": "evt-..."
}
```

Stop when `iteration >= maxIterations` or status becomes `approved`.
