# Dynamics 365 & Power Platform Plugin

A comprehensive plugin for **GitHub Copilot CLI** and **Claude Code** specialized in Dynamics 365 Customer Engagement and Power Platform development.

## Overview

This plugin provides three specialized AI agents and ten skills that cover the complete D365/Power Platform development lifecycle: from solution architecture to code generation, testing, and documentation.

## Installation

### GitHub Copilot CLI

```bash
# Install from the awesome-copilot marketplace
copilot plugin install dynamics365-powerplatform
```

### Claude Code

```bash
# Add as a Claude Code plugin
claude plugin add https://github.com/FranFdezColoma/marketplace/tree/main/plugins/dynamics365-powerplatform
```

## Agents

| Agent | Role | When to use |
|-------|------|-------------|
| **Solution Architect** | Senior architect for D365 CE & Power Platform | Design decisions, data modeling, security, integrations, ALM strategy |
| **Developer** | Senior developer / tech lead | Plugin code, PCF components, Custom APIs, flows, code review, testing |
| **Documenter** | Technical documentation specialist | README, ADR, API docs, arc42, deployment guides, Jira issues |

## Skills

| Skill | Description |
|-------|-------------|
| `code-review` | Code quality review with severity classification (CRITICAL/HIGH/MEDIUM/LOW) |
| `plugin-builder` | C# Dataverse plugin scaffolding (.NET Framework 4.7.1) |
| `custom-api-builder` | Dataverse Custom API creation with C# implementation |
| `cloud-flow-builder` | Power Automate Cloud Flow design with error handling |
| `pcf-builder` | PCF component scaffolding (TypeScript, React, Fluent UI) |
| `doc-generator` | Technical documentation generation (Diátaxis framework) |
| `arc42` | Architecture documentation following the arc42 standard |
| `jira-issue-creator` | Jira/Azure DevOps issue creation (Gherkin for test cases) |
| `unit-test-builder` | Unit test generation (MSTest+Moq for C#, Vitest+xrm-mock for JS) |
| `pull-request` | PR creation with Conventional Commits |

## Configuration

### Publisher Prefix

The plugin uses `{prefix}_` as a configurable placeholder for your Dataverse publisher prefix. Replace it with your organization's prefix (e.g., `contoso_`, `acme_`).

### MCP Integrations

For the best experience, configure these MCP servers:

- **Microsoft Learn MCP**: Provides access to official Microsoft documentation
- **Dataverse MCP**: Enables environment inspection (tables, columns, relationships)
- **Jira MCP** (optional): Enables direct Jira/Azure DevOps issue creation

## Technical Stack

| Area | Technology |
|------|-----------|
| C# Plugins | .NET Framework 4.7.1, Microsoft.CrmSdk.CoreAssemblies |
| C# Testing | MSTest.TestFramework, MSTest.TestAdapter, Moq |
| JS/TS Forms | ES6+, Xrm API |
| JS Testing | Vitest, xrm-mock |
| PCF | TypeScript, React (optional), Fluent UI |

## References

The `references/` folder contains essential standards and patterns:

- **naming-conventions.md** — Naming standards for all D365/PP artifact types
- **dataverse-patterns.md** — Common development patterns (plugins, forms, OData)
- **alm-guidelines.md** — ALM strategy, solutions, environments, pipelines

## Language Policy

- **Internal instructions**: English
- **User responses**: Spanish
- **Code/variables/comments**: English

## License

MIT

## Author

Francisco Fernandez Coloma — [@FranFdezColoma](https://github.com/FranFdezColoma)
