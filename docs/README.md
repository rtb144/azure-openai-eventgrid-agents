# Azure OpenAI Coding & Review Agents — Documentation

Detailed documentation for the event-driven AOAI coding and review agent system that coordinates via Azure Event Grid. Agents use the GitLab instance available in the Azure environment as their source-control system of record.

## Contents

- [Architecture Overview](Architecture-Overview.md)
- [Event Schema](Event-Schema.md)
- [Terraform Guide](Terraform-Guide.md)
- [Agent Implementation](Agent-Implementation.md)
- [GitLab Integration](GitLab-Integration.md)
- [Deployment & Operations](Deployment-Operations.md)

## Quick Links

- Repository: https://github.com/rtb144/azure-openai-eventgrid-agents
- Terraform: `terraform/`
- Diagrams: `diagrams/`

## Enabling the GitHub Wiki

1. Go to the repository **Settings → Features**
2. Check **Wikis**
3. The wiki will be available at `https://github.com/rtb144/azure-openai-eventgrid-agents/wiki`
4. You can then push the contents of this `docs/` folder to the wiki repository (`azure-openai-eventgrid-agents.wiki`)

Alternatively, keep using this `docs/` folder as the primary documentation source (recommended for version control with the code).
