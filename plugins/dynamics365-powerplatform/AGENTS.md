# Dynamics 365 & Power Platform — AI Agent Guidance

This plugin provides three specialized agents for Dynamics 365 Customer Engagement and Power Platform projects. Each agent has a distinct role and expertise area.

## Available Agents

### Solution Architect (`solution-architect`)
Use this agent when you need to design, analyze, or validate technical solutions for Dynamics 365 CE and Power Platform.

**Activation examples**: "design the architecture for", "how would I model the data for", "analyze this requirement", "propose a solution for", "what tables do I need", "design the security model", "what integration pattern to use", "evaluate this technical decision", "OOB or custom?"

### Developer (`developer`)
Use this agent when you need to write, review, or improve code for Power Platform, Dataverse, or Dynamics 365.

**Activation examples**: "write a plugin for", "create a PCF component", "I need a flow that", "create a Custom API", "review this code", "add tests to", "refactor", "create a web resource", "fix this error", "implement", "develop"

### Documenter (`documenter`)
Use this agent when you need to generate, review, or improve technical documentation for Power Platform, Dataverse, or Dynamics 365.

**Activation examples**: "document this component", "generate the README for", "create an ADR for", "write the API documentation", "generate the CHANGELOG", "write a user guide for", "document the data model", "create the runbook for", "write the release notes", "explain this architecture"

## Agent Routing Rules

1. **Architecture/Design questions** → `solution-architect`
2. **Code generation/review** → `developer`
3. **Documentation/reports** → `documenter`
4. If a task spans multiple areas, the primary agent delegates to others as needed.

## Available Skills

All agents can invoke these skills when appropriate:

| Skill | Purpose |
|-------|---------|
| `code-review` | Code quality review with severity levels |
| `plugin-builder` | C# Dataverse plugin scaffolding |
| `custom-api-builder` | Dataverse Custom API creation |
| `cloud-flow-builder` | Power Automate Cloud Flow design |
| `pcf-builder` | PCF component scaffolding |
| `doc-generator` | Technical documentation generation |
| `arc42` | arc42 architecture documentation |
| `jira-issue-creator` | Jira/Azure DevOps issue creation |
| `unit-test-builder` | Unit test generation (C# + JS/TS) |
| `pull-request` | PR creation with Conventional Commits |

## MCP Integrations

- **Microsoft Learn MCP**: For official Microsoft documentation and verified information
- **Dataverse MCP**: For inspecting environment metadata (tables, columns, relationships)
- **Jira MCP**: For creating and managing Jira issues (when available)

## Language Policy

- Internal instructions: English
- Responses to users: Spanish
- Code, variables, comments: English

## Key Conventions

- Publisher prefix: Configurable (`{prefix}_`). Replace with your organization's prefix.
- Solution priority: OOB → Low Code → Pro Code (always argue why simpler options don't suffice)
- C# Plugins: .NET Framework 4.7.1
- Testing: MSTest + Moq (C#), Vitest + xrm-mock (JS/TS)
- Git: Conventional Commits
