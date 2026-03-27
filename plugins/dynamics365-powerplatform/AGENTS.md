# AGENTS.md — Plugin power-platform-dataverse

This file provides guidance to AI Agents when working with the **power-platform-dataverse** plugin.

## What This Plugin Is

A professional development plugin by Capgemini for teams building on **Microsoft Power Platform**, **Dataverse**, and **Dynamics 365**. Provides three specialized agents and eleven skills covering the full development lifecycle: architecture design, pro code development, and technical documentation.

**Compatible with**: GitHub Copilot CLI and Claude Code (AgentSkills standard).

## Plugin Architecture

```
dynamics365-powerplatform/
├── .claude-plugin/
│   └── plugin.json              ← Plugin metadata
├── AGENTS.md                    ← Plugin guidance for AI agents (this file)
├── README.md
├── agents/
│   ├── solution-architect.md    ← Architecture & data model design
│   ├── developer.md             ← Pro code development (C#, TypeScript, flows)
│   └── documenter.md            ← Technical documentation generation
├── skills/
│   ├── dataverse-schema/        ← /dataverse-schema
│   ├── plugin-builder/          ← /plugin-builder
│   ├── pcf-builder/             ← /pcf-builder
│   ├── flow-builder/            ← /flow-builder
│   ├── custom-api/              ← /custom-api
│   ├── alm-pipeline/            ← /alm-pipeline
│   ├── security-design/         ← /security-design
│   ├── doc-generator/           ← /doc-generator
│   ├── code-review/             ← /code-review
│   ├── unit-test-builder/       ← /unit-test-builder
│   └── pull-request/            ← /pull-request
├── references/
│   ├── naming-conventions.md    ← Naming standards for all artifacts
│   ├── dataverse-patterns.md    ← C#, TypeScript, OData best practices
│   └── alm-guidelines.md        ← ALM, environments, pipelines
└── best-practices/
    ├── naming-conventions-en.md ← Naming conventions guide (EN)
    └── unit-testing-es.md       ← Unit testing guide (ES)
```

## Agents

| Agent | Model | When to Use |
|-------|-------|-------------|
| `solution-architect` | opus | Architecture decisions, data modeling, ADRs, security design, integration patterns |
| `developer` | sonnet | C# plugins, Custom APIs, PCF controls, Power Automate flows, code review |
| `documenter` | sonnet | README, ADRs, OpenAPI, changelogs, user guides, architecture diagrams |

## Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/dataverse-schema` | "diseña el modelo", "tablas dataverse" | Dataverse data model with naming, relationships, conventions |
| `/plugin-builder` | "crea un plugin", "plugin c#" | C# Dataverse plugin with full best practices |
| `/pcf-builder` | "crea un pcf", "componente pcf" | PCF control with TypeScript, React, Fluent UI |
| `/flow-builder` | "crea un flow", "power automate" | Power Automate flow with quality standards |
| `/custom-api` | "custom api", "api personalizada" | Dataverse Custom API definition + handler |
| `/alm-pipeline` | "pipeline ci/cd", "alm setup" | GitHub Actions / Azure DevOps pipeline for Power Platform |
| `/security-design` | "modelo de seguridad", "roles dataverse" | Security roles, OWS, column security, DLP |
| `/doc-generator` | "documenta esto", "genera documentación" | Technical documentation following Diátaxis |
| `/code-review` | "revisa el código", "code review" | Code review with 🔴🟡🔵 severity levels |
| `/unit-test-builder` | "crea tests unitarios", "añade tests" | Unit tests: C# (MSTest+Moq) and JS/TS (Vitest+xrm-mock) |
| `/pull-request` | "abre un pr", "crea pull request" | Create PR with git + gh CLI and structured description |

## Conventions

### Language
- **Responses and explanations**: Spanish
- **Code, variable names, comments**: English
- **Publisher prefix example**: `src_`

### Code Standards
See [references/naming-conventions.md](references/naming-conventions.md) for full conventions.

Quick reference:
- **PCF Components**: `src_CustomerCard` (PascalCase with publisher prefix)
- **Custom Dataverse tables**: `src_customer_profile` (snake_case with prefix)
- **TypeScript files**: `customerService.ts` (camelCase)
- **Constants**: `MAX_RETRY_COUNT` (UPPER_SNAKE_CASE)
- **C# classes/methods**: `PascalCase`
- **C# private fields**: `_camelCase`
- **Power Automate flows**: `[Scope]_[Entity]_[Action]` (e.g., `Sales_Opportunity_NotifyOnWin`)

### Quality Principles
- OOB first → Low Code second → Pro Code only when justified
- All pro code in version control (Git)
- Managed Solutions in Test and Production
- CI/CD pipelines for all deployable artifacts
- Solution Checker in every pipeline
- 80%+ test coverage on critical business logic

## Development Guidelines

### Skill Authoring
- Keep `SKILL.md` under 500 lines
- Use `allowed-tools` as space-delimited list (NOT JSON array, NOT comma-separated). Example: `allowed-tools: Bash(git:*) Read Write`
- Write `description` in third person with trigger examples
- Use `EnterPlanMode`/`ExitPlanMode` for multi-step decisions
- Link to references/ inline: `See [naming-conventions.md](../../references/naming-conventions.md)`

### Testing Changes
After modifying this plugin:
1. Test agent activation (mention architecture scenario, coding task, documentation request)
2. Test skill invocation with `/skill-name`
3. Verify PAC CLI integration works (`pac auth list`)
4. Confirm references are accessible from skill context

## External Documentation

- [Dataverse Developer Guide](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/)
- [PCF Documentation](https://learn.microsoft.com/en-us/power-apps/developer/component-framework/)
- [PAC CLI Reference](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference)
- [Power Automate Documentation](https://learn.microsoft.com/en-us/power-automate/)
- [Power Platform Build Tools](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools)
- [Dynamics 365 SDK](https://learn.microsoft.com/en-us/dynamics365/customerengagement/on-premises/developer/developer-guide)
