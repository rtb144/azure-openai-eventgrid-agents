# Agent Implementation

## Recommended Runtime

Azure Functions (Python 3.11) with Event Grid triggers. Each agent is a function (or set of functions) that:

1. Receives a CloudEvent
2. Loads state from Cosmos DB
3. Calls Azure OpenAI
4. Interacts with the GitLab instance available in the Azure environment (create branch, commit, open/update MR, post notes)
5. Writes artifacts to Blob Storage
6. Publishes the next CloudEvent
7. Updates Cosmos DB state

## Coder Agent Responsibilities

- Consume `TaskSubmitted` or `ChangesRequested`
- Construct a prompt that includes requirements + previous review findings (if any)
- Call Azure OpenAI (optionally with code interpreter / tool use)
- Create or update a GitLab branch and commit the generated files
- Open or update a merge request with a clear description
- Package the generated code and store it in Blob Storage (backup / audit)
- Publish `CodeGenerated` with the blob URI and GitLab MR URL/IID
- Increment iteration counter in Cosmos

## Reviewer Agent Responsibilities

- Consume `CodeGenerated`
- Download the artifact from Blob (or clone the GitLab branch)
- Call Azure OpenAI with a structured-output schema (findings array)
- Optionally run static analysis tools
- Post structured review notes / inline comments on the GitLab merge request
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
    ├── blob_store.py
    └── gitlab_client.py   # Thin wrapper around GitLab REST API
```

## GitLab Integration

The agents use the GitLab REST API against the instance already available in the Azure environment.

**Authentication options (prefer in this order):**

1. Project or group access token stored in Azure Key Vault, retrieved by the Function managed identity
2. Fine-grained personal access token (scoped to `api`, `read_repository`, `write_repository`)
3. GitLab MCP server (if the instance is GitLab 19.5+) for tool-based agent interaction

**Minimal required GitLab scopes:** `api` (or more granular `read_api` + write scopes as needed).

**Typical operations:**

- `POST /projects/:id/repository/branches` — create feature branch
- `POST /projects/:id/repository/commits` — commit files (or use the multi-file commit API)
- `POST /projects/:id/merge_requests` — open MR
- `POST /projects/:id/merge_requests/:iid/notes` — post review summary
- `POST /projects/:id/merge_requests/:iid/discussions` — inline comments

See `docs/GitLab-Integration.md` for concrete examples and configuration.

## Prompt Guidance

**Coder system prompt (excerpt)**  
"You are a precise coding agent. Produce complete, runnable code that satisfies the requirements. If review findings are provided, address every major and critical finding. When finished, the code will be committed to a GitLab branch and opened as a merge request."

**Reviewer system prompt (excerpt)**  
"You are a thorough code reviewer. Return only valid JSON matching the Review schema. Focus on correctness, security, and missing tests. Do not invent issues. Your findings will be posted as notes on the GitLab merge request."

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
  "gitlabProjectId": 123,
  "gitlabMergeRequestIid": 45,
  "lastEventId": "evt-..."
}
```

Stop when `iteration >= maxIterations` or status becomes `approved`.
