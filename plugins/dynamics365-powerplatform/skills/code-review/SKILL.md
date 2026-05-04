---
name: code-review
description: Perform specialized code reviews for Dynamics 365 and Power Platform projects. Reviews C# plugins, JavaScript web resources, TypeScript PCF controls, and Power Automate flow definitions with D365-specific best practices enforcement.
---

# Code Review for D365/Power Platform

Targeted, high-quality code reviews for C# plugins, JS web resources, TS PCF controls, and Power Automate flows.

---

## Severity Classification

| Severity | Meaning | Action |
|----------|---------|--------|
| 🔴 Critical | Security flaw, data loss, platform violation | Block deployment |
| 🟠 Major | Perf issue, incorrect behavior, maintainability | Fix this iteration |
| 🟡 Minor | Style, naming, minor optimization | Fix when convenient |
| 🔵 Info | Suggestion or alternative approach | Consider |

---

## C# Plugin Checklist

### Platform/Sandbox (Critical)
- No hardcoded credentials
- No System.IO, System.Net, Thread, Task.Run, async/await
- No static mutable state (plugin instances are reused)
- No reflection on restricted types
- Uses InvalidPluginExecutionException for user errors
- Respects 2-min execution limit

### Correctness
- Validates context: MessageName, Stage, PrimaryEntityName
- Checks `InputParameters.Contains("Target")`
- Checks `entity.Contains("attr")` before access
- Handles nulls from optional attributes
- Correct logical names (case-sensitive, with publisher prefix)
- Pre/Post images used correctly

### Performance
- No RetrieveMultiple inside loops (N+1)
- No `new ColumnSet(true)` — specify columns
- Filters applied in QueryExpression
- Uses TopCount where appropriate
- Avoids redundant service calls when data is in context
- Uses ExecuteMultipleRequest for batch

### Design
- Single responsibility per plugin class
- Uses ITracingService before throwing exceptions
- No dead code or commented blocks
- Secure/Unsecure config used appropriately

---

## JavaScript Web Resource Checklist

### Platform
- Uses `formContext` (NOT deprecated Xrm.Page)
- No jQuery or external frameworks
- No direct DOM manipulation in form scripts
- Namespace pattern: `Publisher.Entity.Event`
- Includes `module.exports` for testability

### Security & Performance
- No sensitive data in client-side code
- Uses `Xrm.WebApi` (not direct XHR/fetch to Dataverse)
- No eval() or dynamic code execution
- No synchronous XMLHttpRequest
- Minimizes Web API calls on form load

### Correctness
- Null checks before field access
- Async/await with try/catch
- Handles form type (Create vs Update)
- Correct field logical names

---

## TypeScript PCF Checklist

- `init()` initializes, `destroy()` cleans up ALL resources
- `updateView()` handles all property changes efficiently
- Manifest declares all bound/input/output properties
- Minimal re-renders, efficient DOM ops
- Input validation, XSS prevention on user content

---

## Power Automate Flow Checklist

- Trigger conditions minimize unnecessary runs
- Connection references used (not embedded connections)
- Environment variables for config values
- Run After configured for failure paths (Try-Catch pattern)
- Avoids Apply to Each when Select/Filter works
- Concurrency control configured
- Secure inputs/outputs for sensitive data
- No hardcoded secrets

---

## Critical Anti-Patterns (ALWAYS Flag)

1. **Infinite Loop** — Plugin triggers itself
2. **N+1 Query** — RetrieveMultiple inside loop
3. **God Plugin** — One class handles multiple messages/entities
4. **Hardcoded GUIDs** — Environment-specific IDs in code
5. **ColumnSet(true)** — Retrieving all columns
6. **Catch-All Silence** — `catch (Exception) { }` with no action
7. **Static State** — Mutable static variables in plugins
8. **Direct SQL** — Accessing Dataverse DB directly

---

## Unit Test Review

### C# (MSTest + Moq)
- AAA pattern with clear sections
- Names: `WhenCondition_ThenExpectedBehavior`
- Full mock chain: IServiceProvider → Factory → Service → Context → Tracing
- `[TestInitialize]` for shared setup
- Factory helpers for test entities
- Tests both happy path and errors

### JavaScript (Vitest + xrm-mock)
- `afterEach(() => vi.clearAllMocks())`
- Xrm mock in `beforeEach`, not module level
- Async tests await + flush microtasks
- Lookups use array format `[{ id, entityType, name }]`
- Uses `module.exports` from source

---

## Output Format

```markdown
## Code Review: [filename]
**Type**: [Plugin | Web Resource | PCF | Flow]
**Assessment**: [Approved | Approved with Comments | Changes Required]

### 🔴 Critical
1. **[Title]** (Line X) — Problem → Impact → Fix

### 🟠 Major
...

### 🟡 Minor
...

### Positive Observations
- [Good practices found]
```
