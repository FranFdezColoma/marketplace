---
name: solution-design
description: Generate a comprehensive Solution Design Document for Dynamics 365 CE and Power Platform projects. Produces a professional Markdown file with Mermaid diagrams covering data model, component architecture, integration, security, and phased implementation. Use when the user has discussed a problem or requirement and needs a formal design document ready for stakeholder presentation.
---

# Solution Design Document Generator

Synthesize conversation context into a professional **Solution Design Document** (`{SolutionName}_SolutionDesign.md`) with Mermaid diagrams. Output is stakeholder-ready.

## When to Use

- Solution approach agreed upon and formal documentation needed
- Stakeholder sign-off required before implementation
- User requests "document the solution" / "create design doc" / "generate architecture"

---

## Output Rules

- File: `{SolutionName}_SolutionDesign.md` (PascalCase)
- **No code generation** — architecture and design only
- Every diagram MUST have a written explanation below it
- Language matches user's language

---

## Required Sections

### 1. Executive Summary
Business problem | Proposed approach (2-3 sentences) | Key decisions | Complexity: Low/Medium/High

### 2. Solution Context Diagram
Mermaid `graph` showing: solution boundary, external actors (users by role), external systems, integration touchpoints.

Explain: who interacts and why, which systems integrate and via what mechanism.

### 3. Dataverse Data Model (ERD)
Mermaid `erDiagram` showing: custom/extended tables, relationships (1:N, N:N, polymorphic), key columns (lookups, choices), alternate keys.

Explain: custom vs OOB table decisions, relationship types (parental vs referential), alternate key strategy, choice design.

### 4. Component Architecture
Mermaid `graph` showing where logic lives: Business Rules (client) | JS Web Resources | PCF | Plugins (sync/async) | Custom APIs | Power Automate | Azure Functions.

Explain: why each component type chosen over alternatives, pipeline stage for plugins, sync vs async justification.

### 5. Integration Architecture (if applicable)
Mermaid `sequenceDiagram` showing: pattern (real-time/batch), direction (in/out/bidirectional), protocol (REST/OData/Service Bus/Webhooks/Virtual Tables), error/retry.

Explain: pattern choice rationale, retry/dead-letter strategy, idempotency, API limits (6000 req/5min/user).

### 6. Security Model
Mermaid `graph` showing: BU hierarchy, roles and scope, teams (owner/access), FLS if applicable.

Explain: BU justification, privilege depths per table, row-level approach, column security, team strategy.

### 7. Key Process Sequence Diagram
At least one `sequenceDiagram` for the most critical business process. Show: actor interactions, plugin pipeline stages, async operations, error paths.

### 8. Solution Strategy & Prioritization

| Priority | Approach | When |
|----------|----------|------|
| 1 | OOB | Platform covers requirement |
| 2 | Low-Code | Business rules, flows, calculated fields |
| 3 | Pro-Code | Complex logic, performance-critical, external integration |

For each component, state priority level and justify if higher complexity chosen.

### 9. Non-Functional Requirements

| NFR | D365/PP Consideration |
|-----|----------------------|
| API Limits | 6000 req/5min/user; 100K actions/day per flow |
| Storage | DB capacity per env, file limits |
| Licensing | Per user / per app / capacity |
| Performance | Plugin <2s sync, query perf, indexes |
| Concurrency | Optimistic concurrency, duplicate detection |
| Scalability | Elastic tables, async patterns |
| Availability | 99.9% SLA, geo-redundancy |
| Compliance | Data residency, audit, GDPR |

### 10. Phased Implementation (if Medium/High complexity)

**Phase 1 — Foundation**: Core data model, security roles, OOB features, business rules
**Phase 2 — Automation**: Flows, BPFs, canvas apps, dashboards
**Phase 3 — Advanced**: Plugins, Custom APIs, PCF, Azure integration

Per phase: components, dependencies, complexity, acceptance criteria.

### 11. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|

Evaluate: API throttling, plugin depth limit (8), flow retention (28d), solution layering, license costs, data migration.

### 12. Decision Log

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|

### 13. Next Steps
Concrete items: what to build first, environments to prepare, dependencies to resolve, POCs to run.

---

## Diagram Inclusion Rules

| Diagram | Always | If Applicable |
|---------|--------|---------------|
| Solution Context | ✅ | — |
| Data Model (ERD) | ✅ | — |
| Component Architecture | ✅ | — |
| Security Model | ✅ | — |
| Integration | — | ✅ External systems |
| Sequence (process) | ✅ (≥1) | — |
| State Diagram | — | ✅ Complex status transitions |

---

## MCP Integration

- **Microsoft Learn MCP** (`microsoft-learn-*`): Verify features, limits, licensing, constraints
- **Dataverse MCP** (`DataverseMcp-*`): Inspect existing tables, security config, solution components

If unavailable: generate based on conversation context, note assumptions to validate.
