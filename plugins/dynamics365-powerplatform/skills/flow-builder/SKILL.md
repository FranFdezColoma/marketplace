---
name: flow-builder
description: Design and document Power Automate Cloud Flows for Dynamics 365 and Power Platform. Provides flow architecture guidance, pattern selection, error handling strategies, and optimization recommendations. Use when the user needs to create, design, or improve Power Automate flows.
---

# Flow Builder for Power Automate

Design and document Cloud Flows for D365 CE and Power Platform. Focus on architecture, patterns, error handling, performance.

---

## Design Template

```markdown
## Flow: [prefix]_[Entity]_[Trigger]_[Purpose]

| Property | Value |
|----------|-------|
| Type | Automated / Scheduled / Instant |
| Trigger | [type + conditions] |
| Owner | [Service account] |
| Solution | [name] |

### Trigger Configuration
- Table / Filter / Column filter

### Steps
1. Scope: Init (variables, env vars)
2. Scope: Try (business logic)
3. Scope: Catch (Run After: failed/timed out → log + notify)

### Connection References
| Ref | Connector | Usage |
|-----|-----------|-------|

### Environment Variables
| Name | Type | Purpose |
|------|------|---------|
```

---

## Key Principles

### Solution-Aware (MANDATORY)
- Create flows inside a solution
- Use Connection References (NOT embedded connections)
- Use Environment Variables for config
- Name: `[prefix]_[Entity]_[Trigger]_[Purpose]`

### Error Handling (Try/Catch/Finally)
```
[Scope: Try] → Business logic → isSuccess = true
[Scope: Catch] (Run After: failed, timed out, skipped)
  → Error details: workflow()['actions']['Try']['error']
  → Log to error table / notify admin
[Scope: Finally] (Run After: all) → Cleanup
```

### Performance
- Use `Select`/`Filter Array` instead of `Apply to Each` when possible
- Enable concurrency on independent iterations
- Use trigger data directly (`triggerBody()?['col']`) to avoid reads
- `Compose` for transforms instead of multiple variable sets

### Security
- Service principal for background flows
- `Secure Inputs/Outputs` for sensitive data
- No hardcoded secrets — use Key Vault or env vars
- Connection References for cross-env portability

---

## Trigger Best Practices

| Trigger | When | Key |
|---------|------|-----|
| Row added | New records | Column filter to reduce runs |
| Row modified | Field changes | ALWAYS use column filter |
| Action performed | Custom API / bound action | User-initiated async |
| Scheduled | Batch processing | Off-peak hours |

### Filter Expressions
```
statecode eq 0 and prioritycode eq 1
(new_type eq 100000000 or new_type eq 100000001)
```

---

## CLI Commands

```powershell
pac solution export --name [SolutionName] --path [output.zip] --managed

# Flow management via PowerShell (pac flow does NOT exist)
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
Get-AdminFlow -EnvironmentName [env-id]
Enable-AdminFlow -EnvironmentName [env-id] -FlowName [flow-id]
Disable-AdminFlow -EnvironmentName [env-id] -FlowName [flow-id]
```

---

## Anti-Patterns

1. No error handling
2. Embedded connections (use Connection References)
3. Hardcoded values (use Environment Variables)
4. Deep nesting (decompose into Child Flows)
5. Apply to Each for simple transforms
6. Unnecessary Dataverse reads (use trigger data)
7. Update triggers that re-trigger themselves (infinite loop)
8. No column filter on triggers (excessive runs)
9. >50 actions in one flow (decompose)
10. Personal account ownership (use service accounts)

---

## Patterns

See `./reference/flow-patterns.md` for: approval, data sync, notification, HTTP webhook, child flow decomposition, retry/recovery, batch processing.
