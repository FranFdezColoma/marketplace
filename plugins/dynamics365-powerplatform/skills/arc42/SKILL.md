---
name: arc42
description: 'Generate architecture documentation following the arc42 template. Supports all 12 sections with Mermaid diagrams, quality trees, risk tables, and technical debt tracking. Specialized for Dynamics 365 and Power Platform solution architectures.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: documentation
  stack: dynamics365-powerplatform
---

# arc42 Architecture Documentation Generator

## What is arc42

arc42 is a template for architecture documentation with 12 sections. It provides a practical, pragmatic approach to documenting software architectures. This skill specializes arc42 for **Dynamics 365 and Power Platform** solutions.

---

## The 12 Sections

### Section 1: Introduction and Goals

Describes business requirements, quality goals, and stakeholders.

**Template:**

```markdown
# 1. Introduction and Goals

## 1.1 Requirements Overview

{Describe the key business requirements that drive the architecture.}

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| R1 | {requirement name} | {High/Medium/Low} | {description} |
| R2 | {requirement name} | {High/Medium/Low} | {description} |

## 1.2 Quality Goals

| Priority | Quality Attribute | Description |
|----------|-------------------|-------------|
| 1 | {e.g., Performance} | {specific quality goal} |
| 2 | {e.g., Security} | {specific quality goal} |
| 3 | {e.g., Maintainability} | {specific quality goal} |

## 1.3 Stakeholders

| Role | Name/Team | Expectations | Influence |
|------|-----------|--------------|-----------|
| {role} | {name} | {what they expect} | {High/Medium/Low} |
| {role} | {name} | {what they expect} | {High/Medium/Low} |
```

---

### Section 2: Architecture Constraints

Documents constraints limiting design decisions. Platform constraints are critical for D365/PP.

**Template:**

```markdown
# 2. Architecture Constraints

## 2.1 Technical Constraints

| ID | Constraint | Description |
|----|-----------|-------------|
| TC1 | Dataverse API Limits | {e.g., 6000 API calls per 5-min window per user} |
| TC2 | Plugin Execution Time | {max 2 minutes per plugin step} |
| TC3 | Flow Run Limits | {daily flow run limits per license type} |
| TC4 | Storage Limits | {Dataverse DB storage, file storage, log storage} |

## 2.2 Organizational Constraints

| ID | Constraint | Description |
|----|-----------|-------------|
| OC1 | {e.g., Team expertise} | {description of team skill constraints} |
| OC2 | {e.g., Budget} | {budget limitations} |
| OC3 | {e.g., Timeline} | {go-live deadline and milestones} |

## 2.3 Convention Constraints

| ID | Constraint | Description |
|----|-----------|-------------|
| CC1 | Naming Convention | {publisher prefix, table naming, field naming} |
| CC2 | Coding Standards | {C# standards for plugins, JS standards for web resources} |
| CC3 | Solution Strategy | {layering approach, solution segmentation} |

## 2.4 D365/PP Platform Constraints

| Constraint | Limit | Reference |
|-----------|-------|-----------|
| Environments per tenant | {limit} | Microsoft Docs |
| Custom tables per solution | {limit} | Platform limit |
| Concurrent plugin executions | {limit} | Platform limit |
```

---

### Section 3: System Scope and Context

Defines system boundaries, external actors, and integration points.

**Template:**

```markdown
# 3. System Scope and Context

## 3.1 Business Context

{Insert Mermaid C4 Context diagram here — see Mermaid templates section below.}

| Actor/System | Description | Input | Output |
|-------------|-------------|-------|--------|
| {actor/system} | {role} | {what it sends} | {what it receives} |

## 3.2 Technical Context

{Insert Mermaid technical context diagram here.}

| Interface | Technology | Protocol | Description |
|-----------|-----------|----------|-------------|
| {interface} | {e.g., Dataverse Web API} | {REST/HTTPS} | {purpose} |
| {interface} | {e.g., Custom Connector} | {REST/HTTPS} | {purpose} |
| {interface} | {e.g., Service Bus} | {AMQP} | {purpose} |

## 3.3 D365/PP Integrations

| Integration | Direction | Technology |
|------------|-----------|-----------|
| {system} | {Inbound/Outbound/Bidirectional} | {Custom API/Webhook/Connector} |
```

---

### Section 4: Solution Strategy

Documents fundamental technology decisions and solution approaches (OOB → Low Code → Pro Code).

**Template:**

```markdown
# 4. Solution Strategy

## 4.1 Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| CRM Module | {Sales / Customer Service / Field Service / Custom} | {justification} |
| Customization Approach | {OOB → Low Code → Pro Code} | {justification} |
| Integration Pattern | {e.g., Event-driven, API-led} | {justification} |
| Portal Technology | {Power Pages / Custom / None} | {justification} |

## 4.2 OOB vs. Low Code vs. Pro Code

For each capability, justify the approach using the Power Platform hierarchy:

| Capability | Approach | Justification |
|-----------|----------|---------------|
| {capability 1} | OOB Configuration | {why OOB is sufficient} |
| {capability 2} | Low Code (Power Automate) | {why low code is needed} |
| {capability 3} | Pro Code (Plugin/PCF) | {why pro code is required} |

## 4.3 Solution Layering Strategy

| Solution | Type | Purpose | Dependencies |
|----------|------|---------|-------------|
| {publisher}_Core | Managed | Core data model and security | None |
| {publisher}_Business | Managed | Business logic and automation | Core |
| {publisher}_UI | Managed | UI customizations and PCF | Core, Business |
| {publisher}_Integration | Managed | External integrations | Core |

## 4.4 Quality Strategies

| Quality Goal | Strategy |
|-------------|----------|
| {e.g., Performance} | {caching strategy, async patterns, batch processing} |
| {e.g., Security} | {security role design, field-level security, BU hierarchy} |
| {e.g., Maintainability} | {solution layering, coding standards, CI/CD} |
```

---

### Section 5: Building Block View

Static decomposition: solutions, plugins, PCF, flows, web resources.

**Template:**

```markdown
# 5. Building Block View

## 5.1 Level 1 — System Overview

{Insert Mermaid diagram showing the overall decomposition.}

| Building Block | Description | Technology |
|---------------|-------------|-----------|
| {block name} | {responsibility} | {Dataverse/Plugin/Flow/PCF/etc.} |

## 5.2 Level 2 — Solution Decomposition

### {Solution Name}

| Component | Type | Description |
|-----------|------|-------------|
| {component} | {Plugin/Flow/PCF/Web Resource/Custom API} | {responsibility} |

## 5.3 Level 3 — Component Detail

- **Type:** {Plugin Step / Cloud Flow / PCF Control}
- **Registration:** {Pre-Validation / Pre-Operation / Post-Operation}
- **Entity/Message:** {table logical name} / {Create / Update / Delete}
```

---

### Section 6: Runtime View

Key scenarios as sequence diagrams, plugin pipelines, and error handling flows.

**Template:**

```markdown
# 6. Runtime View

## 6.1 {Scenario Name}

{Mermaid sequence diagram here.}

## 6.2 Plugin Execution Pipeline

| Step | Stage | Entity | Message | Mode | Description |
|------|-------|--------|---------|------|-------------|
| 1 | Pre-Validation | {entity} | {message} | Sync | {what it does} |
| 2 | Pre-Operation | {entity} | {message} | Sync | {what it does} |
| 3 | Post-Operation | {entity} | {message} | Async | {what it does} |

## 6.3 Error Handling Flow

{Insert Mermaid sequence diagram showing error handling.}

| Error Type | Handler | Action | Notification |
|-----------|---------|--------|-------------|
| {error type} | {Plugin/Flow/UI} | {retry/log/alert} | {who is notified} |
```

---

### Section 7: Deployment View

Environment topology, CI/CD pipeline, managed vs. unmanaged solutions.

**Template:**

```markdown
# 7. Deployment View

## 7.1 Environment Topology

{Insert Mermaid deployment diagram — see templates section.}

| Environment | Type | Purpose | URL |
|------------|------|---------|-----|
| DEV | Sandbox | Development and unit testing | {url} |
| TEST | Sandbox | Integration and QA testing | {url} |
| UAT | Sandbox | User acceptance testing | {url} |
| PROD | Production | Live system | {url} |

## 7.2 Solution Deployment Pipeline

| Step | Action | Tool | Trigger |
|------|--------|------|---------|
| 1 | Export solution | PAC CLI / Pipeline | Commit to main |
| 2 | Build and test | Azure DevOps / GitHub Actions | Automated |
| 3 | Deploy to TEST → UAT → PROD | Power Platform Pipelines | Approval gates |

## 7.3 Azure Resources (if applicable)

| Resource | Type | Purpose |
|----------|------|---------|
| {resource} | {e.g., Azure Function / Service Bus / App Insights} | {purpose} |
```

---

### Section 8: Cross-cutting Concepts

Security model, error handling, logging, data migration, and performance patterns.

**Template:**

```markdown
# 8. Cross-cutting Concepts

## 8.1 Security Model

### Business Unit Hierarchy
{Describe the BU structure and its purpose.}

### Security Roles

| Role | Base Role | Scope | Description |
|------|-----------|-------|-------------|
| {role} | {base} | {BU/Parent-Child/Organization} | {access level} |

### Field-Level Security

| Table | Field | Profile | Access |
|-------|-------|---------|--------|
| {table} | {field} | {profile name} | {Read/Update/Create} |

## 8.2 Error Handling Strategy

| Layer | Strategy | Implementation |
|-------|----------|---------------|
| Plugin | {try-catch, InvalidPluginExecutionException} | {details} |
| Cloud Flow | {try-catch scope, configure run after} | {details} |
| UI/PCF | {error boundaries, notifications} | {details} |
| Integration | {retry policy, dead letter queue} | {details} |

## 8.3 Logging and Monitoring

| What | Tool |
|------|------|
| Plugin telemetry | Application Insights (ILogger) |
| Flow run history | Power Automate |
| Audit trail | Dataverse Audit |

## 8.4 Data Migration

| Source | Target Table | Method | Volume |
|--------|-------------|--------|--------|
| {source} | {table} | {SDK/Import Wizard/SSIS/Dataflows} | {row count} |

## 8.5 Performance

| Area | Strategy |
|------|----------|
| Queries | Indexed columns, filtered views |
| Plugins | Async where possible, early exit |
| Integration | Batching, pagination, throttling |
```

---

### Section 9: Architecture Decisions

Numbered ADR list linking to individual ADR files from the doc-generator skill.

**Template:**

```markdown
# 9. Architecture Decisions

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-001 | {decision title} | {Proposed/Accepted/Deprecated/Superseded} | {date} |
| ADR-002 | {decision title} | {Proposed/Accepted/Deprecated/Superseded} | {date} |

## ADR-001: {Decision Title}

- **Status:** {Proposed | Accepted | Deprecated | Superseded by ADR-XXX}
- **Date:** {YYYY-MM-DD}
- **Context:** {What is the issue we are deciding on?}
- **Decision:** {What is the chosen approach?}
- **Consequences:** {What are the implications, both positive and negative?}
- **Alternatives Considered:**
  1. {alternative 1} — {why rejected}
  2. {alternative 2} — {why rejected}

> For detailed ADRs, use the `doc-generator` skill to create individual ADR files.
```

---

### Section 10: Quality Requirements

Quality tree and measurable quality scenarios.

**Template:**

```markdown
# 10. Quality Requirements

## 10.1 Quality Tree

| Category | Quality Attribute | Sub-Attribute |
|----------|-------------------|---------------|
| Performance | Response time | Page load < 3s |
| Security | Authentication | Azure AD / Entra ID SSO |
| Security | Authorization | Role-based, field-level |
| Reliability | Availability | 99.9% uptime (platform SLA) |
| Maintainability | Testability | Unit test coverage > 80% |

## 10.2 Quality Scenarios

| ID | Quality Attribute | Scenario | Measure | Priority |
|----|-------------------|----------|---------|----------|
| QS-01 | {attribute} | {when X happens, the system should Y} | {measurable target} | {High/Medium/Low} |
| QS-02 | {attribute} | {when X happens, the system should Y} | {measurable target} | {High/Medium/Low} |
```

---

### Section 11: Risks and Technical Debt

Risk register, D365/PP-specific risks (API limits, deprecations), and technical debt.

**Template:**

```markdown
# 11. Risks and Technical Debt

## 11.1 Risk Register

| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R-01 | {risk description} | {High/Medium/Low} | {High/Medium/Low} | {mitigation strategy} |
| R-02 | API throttling under peak load | Medium | High | Retry with exponential backoff, batch operations |

## 11.2 D365/PP-Specific Risks

| Risk | Mitigation |
|------|------------|
| API call limits (6000/5-min/user) | Batch operations, efficient queries |
| Licensing changes | Annual license review, cost monitoring |
| Feature deprecation | Follow Microsoft deprecation notices |

## 11.3 Technical Debt Register

| ID | Description | Impact | Effort | Priority |
|----|-------------|--------|--------|----------|
| TD-01 | {description} | {consequence} | {S/M/L/XL} | {High/Medium/Low} |
```

---

### Section 12: Glossary

Terms, abbreviations, and D365/PP-specific definitions.

**Template:**

```markdown
# 12. Glossary

## Terms

| Term | Definition |
|------|-----------|
| {term} | {definition} |

Include project-specific abbreviations and D365/PP terms (Dataverse, Managed Solution, Plugin, Cloud Flow, PCF, Custom API, Model-Driven App, BU, FLS, OOB, etc.).
```

See `references/arc42-template.md` for the full glossary and Mermaid diagram templates (C4 Context, Deployment, Sequence, Solution Layering, Quality Tree).

---

## Workflow

1. **Understand scope**: Ask user — full architecture (all 12 sections), specific sections, or a detail level?
2. **Gather context**: Use Dataverse MCP (`list_tables`, `describe_table`, `list_apps`) and Microsoft Learn MCP to auto-fill data model info and link official docs.
3. **Generate**: Produce requested sections using the templates above, customized for the project.
4. **Diagrams**: Add Mermaid diagrams in every applicable section.
5. **Iterate**: Present and refine.

---

## Progressive Detail Levels

| Level | Sections | Audience |
|-------|----------|----------|
| Executive Summary | 1–4 | Stakeholders, sponsors |
| Development Guide | 5–8 | Developers, tech leads |
| Quality Focus | 9–12 | Architects, governance |
| Full Document | 1–12 | Critical projects, handovers |

---

## References

- [arc42 Official Website](https://arc42.org/)
- [arc42 Template (English)](https://arc42.org/download)
- See `references/arc42-template.md` for the section skeleton
- Use the `doc-generator` skill for individual ADR generation
