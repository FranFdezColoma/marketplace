---
name: arc42
description: Generate arc42 architecture documentation tailored for Dynamics 365 Customer Engagement and Power Platform solutions. Use when the user needs to create or update solution architecture documentation following the arc42 template.
---

# arc42 for D365/Power Platform

Generate arc42 architecture documentation adapted for D365 CE and Power Platform.

---

## Sections (D365-Adapted)

### 1. Introduction and Goals
Business problem, requirements table (ID/Description/Priority), quality goals (with measurable scenarios), stakeholders.

### 2. Architecture Constraints
Platform-specific constraints that MUST be documented:
- **Dataverse**: API limits (6000 req/5min/user), storage quotas, file size limits
- **Plugins**: 2-min timeout, sandbox isolation, no Thread/Task, no System.IO/Net
- **Licensing**: Feature availability per license type
- **Network/Data residency**: Cross-region rules, VPN constraints
- **Governance**: Change management, solution publisher ownership

### 3. System Scope and Context
- **Business context**: Users by role, external systems (ERP, BI, email, telephony, portals)
- **Technical context**: Dataverse Web API endpoints, Custom APIs, Service Bus topics, webhooks, Power Automate HTTP connectors

### 4. Solution Strategy
Key decisions:
- Platform choice justification (why D365 vs custom)
- Customization approach: OOB → Low-Code → Pro-Code (with rationale)
- Integration: sync vs async, real-time vs batch
- Data: Dataverse as master vs integration hub
- Security: role-based + field-level + record-level
- ALM: solution segmentation, CI/CD, branching

### 5. Building Block View
**Level 1**: D365 apps, custom model-driven apps, canvas apps, flows, Azure services, integrations
**Level 2**: Dataverse tables/relationships, plugins + registration, web resources, PCF, Custom APIs, security roles
**Level 3** (complex components): Plugin pipeline config, class diagrams, service interactions

### 6. Runtime View
Sequence diagrams for: record creation + validation, integration data flows, approval processes, error/retry flows, batch processing.

### 7. Deployment View
- Environment strategy: Dev → QA → UAT → Prod
- Solutions: managed vs unmanaged, segmentation strategy
- Pipeline: Azure DevOps / GitHub Actions / PAC CLI
- Per-environment config: connection references, environment variables
- Data migration strategy

### 8. Cross-cutting Concepts
Error handling (logging, retry, notification) | Security (authn/authz/data protection) | Monitoring (App Insights, audit) | Performance (caching, query optimization) | i18n (multi-language/currency) | Data archival (retention, bulk delete)

### 9. Architecture Decisions
Use ADR format: Status, Context, Decision, Consequences (+/-).

### 10. Quality Requirements
Table: Quality Attribute | Scenario | Measure. Include: form load time, concurrent users, integration retry SLA, security zero-tolerance.

### 11. Risks and Technical Debt
Platform limitations, accumulated debt, preview feature dependencies, third-party risks.

### 12. Glossary
D365/PP terms, business domain terms, acronyms, business↔technical entity mapping.

---

## Workflow

1. Sections 1-4 first (strategic) → 5-7 as solution takes shape → 8-12 continuously
2. Review at sprint boundaries
3. Use Mermaid diagrams with consistent C4-style notation
4. Ensure all decisions trace to requirements
