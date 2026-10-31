# Architecture Overview

## System Purpose

Event-driven multi-agent system on Azure that uses Azure OpenAI to generate and review code. Agents coordinate asynchronously via Azure Event Grid (CloudEvents) rather than direct calls. A GitLab instance available in the Azure environment serves as the primary source-control and collaboration surface for the agents.

## High-Level Components

| Component | Role | Azure Service / System |
|-----------|------|------------------------|
| **Coder Agent** | Generates or revises code from requirements or review feedback | Azure Functions (Python) |
| **Reviewer Agent** | Performs LLM + optional static review; returns structured findings | Azure Functions (Python) |
| **Event Bus** | Routes coordination events between agents | Azure Event Grid Custom Topic |
| **Artifact Store** | Holds generated code, diffs, and intermediate results | Azure Blob Storage |
| **Workflow State** | Tracks task status, iteration count, correlation | Azure Cosmos DB |
| **LLM Backend** | Powers both agents | Azure OpenAI |
| **Source Control** | Branches, commits, merge requests, discussions | GitLab (available in the Azure environment) |
| **Observability** | Traces, logs, metrics | Application Insights + Log Analytics |
| **Identity** | Secure service-to-service access | Managed Identity + RBAC |

## Coordination Pattern

The system uses **choreography** (not central orchestration):

1. External trigger publishes `TaskSubmitted` (optionally referencing a GitLab issue or MR)
2. Coder Agent consumes it, generates code, creates/updates a GitLab branch + commit (and optional MR), stores artifact in Blob, publishes `CodeGenerated`
3. Reviewer Agent consumes `CodeGenerated`, performs review, posts structured comments on the GitLab MR, publishes `ReviewCompleted` or `ChangesRequested`
4. If changes are requested, Coder Agent iterates (up to a configurable maximum)
5. On approval or max iterations, a terminal event is published and the MR is left ready for human merge (or auto-merged if policy allows)

## Architecture Diagram

See `diagrams/architecture.mmd` (Mermaid) or run `diagrams/generate_diagram.py` (Python diagrams library + Graphviz) for the visual.

## Design Principles

- **Loose coupling**: Agents communicate only via events
- **Idempotency**: Handlers keyed on `taskId` + `iteration`
- **Bounded iteration**: Explicit max iterations to prevent loops
- **Structured output**: Reviewer returns JSON schema for reliable parsing
- **Managed identity**: No secrets in code; RBAC for all Azure access
- **GitLab as system of record**: Branches, MRs, and review discussions live in the existing GitLab instance
