# GitLab Integration

The Azure environment already has a GitLab instance available. The coding and review agents use it as the system of record for branches, commits, and merge requests.

## Configuration

Store the following in Azure Key Vault (or Function App settings protected by Key Vault references):

| Setting | Example | Purpose |
|---------|---------|---------|
| `GITLAB_URL` | `https://gitlab.internal.company.com` | Base URL of the GitLab instance |
| `GITLAB_TOKEN` | (secret) | Project or group access token |
| `GITLAB_PROJECT_ID` | `123` | Default project ID (can be overridden per task) |

The Function App managed identity needs `Key Vault Secrets User` on the vault.

## Minimal Python Client Pattern

```python
import os
import requests

class GitLabClient:
    def __init__(self):
        self.base = os.environ["GITLAB_URL"].rstrip("/")
        self.token = os.environ["GITLAB_TOKEN"]
        self.headers = {"PRIVATE-TOKEN": self.token}

    def create_branch(self, project_id: int, branch: str, ref: str = "main"):
        return requests.post(
            f"{self.base}/api/v4/projects/{project_id}/repository/branches",
            headers=self.headers,
            json={"branch": branch, "ref": ref},
        ).json()

    def commit_files(self, project_id: int, branch: str, message: str, actions: list):
        return requests.post(
            f"{self.base}/api/v4/projects/{project_id}/repository/commits",
            headers=self.headers,
            json={
                "branch": branch,
                "commit_message": message,
                "actions": actions,  # [{"action": "create", "file_path": "...", "content": "..."}]
            },
        ).json()

    def create_merge_request(self, project_id: int, source: str, target: str, title: str, description: str):
        return requests.post(
            f"{self.base}/api/v4/projects/{project_id}/merge_requests",
            headers=self.headers,
            json={
                "source_branch": source,
                "target_branch": target,
                "title": title,
                "description": description,
            },
        ).json()

    def post_note(self, project_id: int, mr_iid: int, body: str):
        return requests.post(
            f"{self.base}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes",
            headers=self.headers,
            json={"body": body},
        ).json()
```

## Recommended Workflow

1. **Coder Agent** creates a branch named `agent/task-{taskId}-iter-{iteration}`
2. Commits the generated files via the multi-file commit API
3. Opens (or updates) a merge request whose description includes the original requirements and a link back to the task
4. Publishes `CodeGenerated` containing `gitlabMergeRequestIid` and `gitlabProjectId`
5. **Reviewer Agent** posts a summary note and, when possible, inline discussion comments for each finding
6. On final approval the MR is left open for human merge (or auto-merged if branch protection and policy allow)

## Authentication Notes

- Prefer a **project access token** or **group access token** with the narrowest scopes needed (`api` or `read_repository` + `write_repository`).
- Rotate the token periodically; store only the secret in Key Vault.
- If the GitLab instance is GitLab 19.5 or later, consider the built-in MCP server at `/api/v4/mcp` for richer tool-based agent interaction.
- Network: ensure the Function App (or its VNet integration) can reach the GitLab URL. Prefer private endpoints or VNet peering when GitLab is self-hosted inside Azure.

## Event Payload Additions

Events may carry GitLab context:

```json
{
  "taskId": "task-12345",
  "iteration": 1,
  "gitlabProjectId": 123,
  "gitlabMergeRequestIid": 45,
  "gitlabBranch": "agent/task-12345-iter-1",
  "blobUri": "https://st....blob.core.windows.net/code-artifacts/..."
}
```

## Security

- Never log the GitLab token.
- Use managed identity for Key Vault access.
- Restrict the token to the specific project or group.
- Consider GitLab webhooks → Event Grid for bi-directional awareness (MR merged, pipeline finished, etc.).
