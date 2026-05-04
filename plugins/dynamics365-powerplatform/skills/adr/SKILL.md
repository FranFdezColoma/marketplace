---
name: adr
description: Create Architecture Decision Records (ADRs) for Dynamics 365 CE and Power Platform projects following the MADR standard. Use when a significant technical or architectural decision needs to be documented — platform choice, customization approach, integration strategy, data model design, security model, ALM strategy, or any decision that is hard to reverse or has broad impact.
---

# ADR Creator for D365 CE / Power Platform

Generate ADRs following the [MADR standard](https://adr.github.io/madr/) adapted for the D365/Power Platform ecosystem.

---

## When to Write an ADR

Write an ADR for decisions that are:
- **Hard to reverse** — data model changes, solution layering, integration architecture
- **Architecturally significant** — affect multiple components, teams, or future options
- **Contentious** — multiple viable options existed and context matters for future reviewers
- **Platform-specific trade-offs** — OOB vs. Low-Code vs. Pro-Code, managed vs. unmanaged, sync vs. async

Do NOT write ADRs for implementation details (e.g., variable naming, minor UI tweaks).

---

## ADR Template

When asked to create an ADR, produce a file with this structure:

```markdown
# ADR-[NNNN]: [Short title — what was decided]

| Field | Value |
|-------|-------|
| **Status** | Proposed \| Accepted \| Deprecated \| Superseded by ADR-XXXX |
| **Date** | YYYY-MM-DD |
| **Deciders** | [Names or roles involved] |
| **Technical area** | [Plugin \| Flow \| PCF \| Custom API \| Data Model \| Security \| ALM \| Integration \| Other] |

## Context and Problem Statement

[2–4 sentences describing the situation and the question that needs to be answered.
What is the driving force? What constraint or requirement makes this a real decision?]

## Decision Drivers

- [Most important driver — business, technical, or operational]
- [Second driver]
- [Third driver — e.g., platform constraint, licensing, team capability]

## Considered Options

1. [Option A — short label]
2. [Option B — short label]
3. [Option C — short label]

## Decision Outcome

**Chosen option: [Option X]**

[1–3 sentences explaining why this option wins. Reference the decision drivers.]

### Consequences

**Positive:**
- [Benefit 1]
- [Benefit 2]

**Negative / Trade-offs:**
- [Trade-off 1]
- [Trade-off 2]

**Follow-up actions:**
- [ ] [Action required as a result of this decision]

---

## Analysis of Options

### Option A: [Label]

[Brief description — what it is and how it would work in this context.]

| | |
|-|-|
| ✅ | [Advantage] |
| ✅ | [Advantage] |
| ❌ | [Disadvantage] |
| ❌ | [Disadvantage] |

### Option B: [Label]

[Brief description.]

| | |
|-|-|
| ✅ | [Advantage] |
| ❌ | [Disadvantage] |

### Option C: [Label]

[Brief description.]

| | |
|-|-|
| ✅ | [Advantage] |
| ❌ | [Disadvantage] |

---

## D365/Power Platform Considerations

> Fill only the sections relevant to this ADR. Delete the rest.

**Solution strategy:**
- Managed or unmanaged layer affected
- Publisher prefix impact
- ALM promotion path (Dev → UAT → Prod)

**Platform constraints:**
- Sandbox restrictions (plugins), API limits, licensing tier required
- Power Platform environment type (Sandbox / Production / Developer)

**OOB vs. customization:**
- What can be achieved with standard configuration vs. what requires customization
- Justification if Pro-Code was chosen over Low-Code

**Licensing implications:**
- Premium connectors, Per-App vs. Per-User, D365 app license requirements

**Reversibility:**
- Can this be undone without data loss or breaking changes?
- Migration path if the decision is later reversed

---

## Links

- [Related ADR] ADR-XXXX: [Title]
- [Reference] [Microsoft Learn / documentation URL]
- [Jira / work item] [Link]
```

---

## Process

1. **Gather context** — ask for: the problem being solved, options already considered, key constraints (licensing, timeline, team skill, existing architecture)
2. **Use Microsoft Learn MCP** to verify platform capabilities and constraints before recommending options
3. **Use Dataverse MCP** if the decision involves the current environment's configuration or schema
4. **Draft the ADR** — complete all sections; leave none blank
5. **Save** the file following your project's ADR naming convention (`ADR-[NNNN]-[kebab-title].md`) in the location defined by your project's custom instructions
6. **Suggest follow-up actions** — if the ADR creates implementation tasks, suggest creating Jira issues (use the `jira-issue-creator` skill)

---

## D365/PP Decision Patterns (Quick Reference)

| Scenario | Typical Options | Key Driver |
|----------|----------------|------------|
| Automate business logic | Business Rule / Flow / Plugin | Complexity + sandbox |
| Extend UI | Model-driven form JS / PCF | Reusability + maintainability |
| External data access | Virtual Table / Integration Flow / Custom API | Latency + licensing |
| Cross-system integration | Dataverse connector / Azure Service Bus / Custom API | Volume + reliability |
| Calculated fields | Formula column / Rollup / Plugin | Real-time vs. scheduled |
| Security scoping | Business Unit hierarchy / Teams / Column security | Org structure alignment |
| Solution packaging | Single solution / Layered solutions / Segmented | Team size + release cadence |
| ALM automation | PAC CLI pipelines / Azure DevOps / Power Platform Pipelines | Governance requirements |
