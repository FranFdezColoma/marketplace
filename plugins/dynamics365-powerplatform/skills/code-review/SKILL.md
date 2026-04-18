---
name: code-review
description: 'Perform structured code reviews for Dynamics 365 and Power Platform code. Analyzes C# plugins, JavaScript/TypeScript web resources, Power Automate flows, and PCF components. Classifies issues by severity (CRITICAL, HIGH, MEDIUM, LOW) and provides actionable recommendations.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: quality
  stack: dynamics365-powerplatform
---

# Code Review — Dynamics 365 & Power Platform

Perform structured code reviews on C# plugins, JavaScript/TypeScript web resources, Power Automate Cloud Flows, and PCF components for Dynamics 365 and Power Platform.

## 1. Severity Classification

Classify every finding into one of these severity levels:

### 🔴 CRITICAL
- Security vulnerabilities (SQL injection, XSS, insecure deserialization)
- Data loss risk (missing transaction handling, unchecked deletes)
- Runtime crashes (null reference in critical paths, unhandled exceptions that crash the plugin pipeline)
- Infinite loops or recursive calls without exit conditions
- Privilege escalation or impersonation misuse

### 🟠 HIGH
- Performance issues: N+1 queries, `RetrieveMultiple` inside loops, missing batching with `ExecuteMultipleRequest`
- Missing error handling in critical code paths
- API limit violations (exceeding Dataverse API protection limits, throttling misuse)
- Hardcoded secrets, connection strings, or credentials in source code
- Missing input validation on plugin context parameters
- Deprecated API usage that will break in future updates

### 🟡 MEDIUM
- Code style violations against project conventions
- Missing validation on non-critical paths
- Poor naming (variables, methods, classes not following C# or JS conventions)
- Missing XML doc comments on public methods or complex business logic
- Overly complex methods (cyclomatic complexity > 10)
- Magic numbers or strings without named constants

### 🔵 LOW
- Minor style issues (spacing, ordering of members)
- Suggested improvements for readability
- Optional performance optimizations with marginal impact
- Missing but non-essential logging or tracing statements

## 2. C# Plugin Review Checklist

When reviewing a C# Dataverse plugin, verify ALL of the following:

### Project Configuration
- [ ] Target framework is **.NET Framework 4.7.1** (`net471`)
- [ ] NuGet package `Microsoft.CrmSdk.CoreAssemblies` is referenced
- [ ] Assembly is signed (required for plugin registration)

### Plugin Structure
- [ ] Class implements `IPlugin` interface correctly
- [ ] `Execute(IServiceProvider serviceProvider)` method is present
- [ ] Services are resolved from `IServiceProvider`:
  - `IPluginExecutionContext`
  - `IOrganizationServiceFactory`
  - `ITracingService`
- [ ] `IOrganizationService` is created via factory: `factory.CreateOrganizationService(context.UserId)`

### Logging and Tracing
- [ ] Uses `ITracingService` for all logging (not `Console.WriteLine`, `Debug.WriteLine`, or `Trace.WriteLine`)
- [ ] Trace messages at start and end of execution
- [ ] Trace messages before and after significant operations

### Exception Handling
- [ ] All user-facing errors thrown as `InvalidPluginExecutionException`
- [ ] Generic exceptions caught and wrapped in `InvalidPluginExecutionException`
- [ ] `InvalidPluginExecutionException` is re-thrown, never swallowed
- [ ] Exception details are traced before re-throwing

### Prohibited Patterns
- [ ] **No `Thread.Sleep`** — plugins must not block the execution thread
- [ ] **No `async/await`** — Dataverse plugin sandbox does not support async execution
- [ ] **No static mutable state** — plugins are stateless; static fields cause race conditions
- [ ] **No `HttpClient` or external HTTP calls** — unless absolutely necessary and approved; use Secure/Unsecure configuration for URLs
- [ ] **No `System.IO` file operations** — sandboxed plugins cannot access the filesystem
- [ ] **No hardcoded GUIDs** — use queries or configuration to resolve record IDs
- [ ] **No hardcoded URLs or credentials** — use Secure Configuration or Environment Variables

### Performance
- [ ] **No `RetrieveMultiple` inside loops** — batch queries or use FetchXML joins instead
- [ ] Respects the **2-minute execution timeout** for synchronous plugins
- [ ] Uses `ColumnSet` with specific columns (never `new ColumnSet(true)` unless justified)
- [ ] Uses `QueryExpression` or `FetchXml` with appropriate filters (no full-table scans)
- [ ] Uses `ExecuteMultipleRequest` for batch operations

### Context and Entity Handling
- [ ] Validates `InputParameters["Target"]` exists and is of expected type (`Entity` or `EntityReference`)
- [ ] Uses early-bound or late-bound types **consistently** (not mixed)
- [ ] Proper use of Pre-Image and Post-Image entities (registered correctly)
- [ ] Handles shared variables correctly when passing data across pipeline steps
- [ ] Checks `context.Depth` to prevent infinite recursion in update triggers

### Security
- [ ] Uses `context.UserId` or `context.InitiatingUserId` appropriately for service creation
- [ ] Does not escalate privileges by using `null` in `CreateOrganizationService(null)` without justification
- [ ] Sensitive data is not written to trace logs

## 3. JavaScript / TypeScript Web Resource Review Checklist

When reviewing form scripts or web resources:

### API Usage
- [ ] Uses `formContext` API (NOT `Xrm.Page` — deprecated since v9.0)
- [ ] `executionContext.getFormContext()` is used to obtain `formContext`
- [ ] No synchronous `XMLHttpRequest` calls — use `Xrm.WebApi` or async `fetch`
- [ ] Uses `Xrm.WebApi.retrieveRecord` / `retrieveMultipleRecords` for data operations

### Dependencies
- [ ] **No jQuery dependency** — not supported in Unified Interface
- [ ] No external CDN references — all libraries must be uploaded as web resources
- [ ] Minimal third-party library usage

### Null Safety and Validation
- [ ] Null checks before accessing form fields: `formContext.getAttribute("fieldname")` may return `null`
- [ ] Null checks on `.getValue()` before using the value
- [ ] Validates control existence before manipulating visibility or disabled state

### Module Pattern
- [ ] Proper namespace pattern used: `Prefix.Entity.Event` (e.g., `Contoso.Account.OnLoad`)
- [ ] Module exports pattern present at end of file for testability:
  ```javascript
  if (typeof module !== "undefined" && module.exports) {
      module.exports = { func1, func2 };
  }
  ```

### Error Handling
- [ ] All async operations wrapped in try/catch
- [ ] User notifications via `Xrm.Navigation.openAlertDialog` or `formContext.ui.setFormNotification`
- [ ] Errors are not silently swallowed

### Prohibited Patterns
- [ ] **No hardcoded GUIDs** — use lookups or queries
- [ ] **No hardcoded URLs** — use `Xrm.Utility.getGlobalContext().getClientUrl()`
- [ ] **No `alert()` or `confirm()`** — use `Xrm.Navigation` methods
- [ ] **No direct DOM manipulation** of CRM form elements — use only supported SDK methods

## 4. Power Automate Cloud Flow Review Checklist

When reviewing flow definitions (JSON or screenshots):

### Naming and Structure
- [ ] Flow name follows convention: `[Scope]_[Entity]_[Action]` (e.g., `CRM_Account_OnCreate_SendWelcomeEmail`)
- [ ] Actions and steps have descriptive names (not default names like "Apply_to_each")
- [ ] Scopes are used to group related actions logically

### Connection and Configuration
- [ ] Uses **Connection References** (not embedded connections) for solution portability
- [ ] Uses **Environment Variables** for URLs, email addresses, and other configuration
- [ ] No hardcoded values that vary between environments

### Error Handling
- [ ] Scope-based error handling implemented (try/catch/finally pattern):
  - **Try** scope: main logic
  - **Catch** scope: error handling with `run-after` configured for `Failed`, `Skipped`, `TimedOut`
  - **Finally** scope: cleanup actions
- [ ] `run-after` configuration is explicitly set for error paths
- [ ] Error notifications sent to administrators on failure

### Performance
- [ ] No unnecessary `Apply to Each` loops — use filter queries or `Select` action instead
- [ ] Pagination handling for large datasets (`@odata.nextLink` or `$top`/`$skip`)
- [ ] Concurrency settings configured appropriately for `Apply to Each` (default is 20, reduce for rate-limited APIs)
- [ ] `Chunk` or batching strategy for processing large record sets

### Security
- [ ] Service principal or dedicated service account used for connections (not personal accounts)
- [ ] Sensitive data not logged in `Compose` or `Initialize Variable` actions
- [ ] Flows run with least-privilege permissions

### Data Operations
- [ ] `List Records` actions use `$filter` and `$select` OData parameters
- [ ] FetchXML queries in Dataverse connector are optimized
- [ ] No redundant data retrieval (query once, reuse)

## 5. PCF Component Review Checklist

When reviewing Power Apps Component Framework (PCF) controls:

### Manifest
- [ ] `ControlManifest.Input.xml` is complete and correct
- [ ] Control namespace and constructor match implementation
- [ ] All bound/input/output properties are declared with correct types
- [ ] Feature usage declarations are present if needed (`WebAPI`, `Device`, `Utility`)

### TypeScript Implementation
- [ ] Proper TypeScript types used — no `any` type unless absolutely justified
- [ ] `init()` method sets up event listeners and initial state
- [ ] `updateView()` handles re-rendering efficiently (no full re-renders on every call)
- [ ] `destroy()` method cleans up:
  - Remove event listeners
  - Dispose of timers/intervals
  - Unmount React components (if applicable)
  - Release external resources
- [ ] `getOutputs()` returns correct values when control modifies data

### React-Specific (if applicable)
- [ ] React components rendered via `ReactDOM.render` in `updateView()`
- [ ] `ReactDOM.unmountComponentAtNode` called in `destroy()`
- [ ] Proper React reconciliation — avoid `key` changes that force full re-mounts
- [ ] No direct DOM manipulation alongside React rendering
- [ ] State management is efficient (no unnecessary re-renders)

### Performance
- [ ] Large datasets use virtual scrolling or pagination
- [ ] Heavy computations are debounced or throttled
- [ ] Images and resources are optimized
- [ ] Bundle size is reasonable (check for unnecessary imports)

## 6. Output Format

Structure every code review using this format:

```markdown
# Code Review: {Component Name}

**Reviewer**: AI Code Review Agent
**Date**: {YYYY-MM-DD}
**Component Type**: C# Plugin | Web Resource | Cloud Flow | PCF Component
**Files Reviewed**: List of files

## Summary

| Severity | Count |
|----------|-------|
| 🔴 CRITICAL | N |
| 🟠 HIGH | N |
| 🟡 MEDIUM | N |
| 🔵 LOW | N |

**Overall Assessment**: PASS ✅ | PASS WITH CONDITIONS ⚠️ | FAIL ❌

## Findings

### 🔴 CRITICAL — {Title}
**File**: `path/to/file.cs`
**Line(s)**: XX-YY
**Issue**: Clear description of what is wrong.
**Impact**: What could go wrong if this is not fixed (data loss, crash, security breach, etc.).
**Fix**:
Recommended solution with code example:
```csharp
// Corrected code here
```

### 🟠 HIGH — {Title}
**File**: `path/to/file.cs`
**Line(s)**: XX-YY
**Issue**: Description of the problem.
**Impact**: Performance degradation, unhandled errors, etc.
**Fix**: Recommended solution with code example.

### 🟡 MEDIUM — {Title}
**File**: `path/to/file.cs`
**Line(s)**: XX-YY
**Issue**: Description.
**Suggestion**: How to improve.

### 🔵 LOW — {Title}
**File**: `path/to/file.cs`
**Line(s)**: XX-YY
**Suggestion**: Optional improvement.

## Recommendations

Prioritized list of actions the developer should take:

1. **[CRITICAL]** Fix {issue} immediately before merging — {brief reason}
2. **[HIGH]** Address {issue} in this PR — {brief reason}
3. **[MEDIUM]** Consider {improvement} — {brief reason}
4. **[LOW]** Optional: {suggestion}
```

## 7. Review Workflow

Follow these steps when performing a code review:

1. **Identify the component type** — determine if the code is a C# plugin, web resource, cloud flow, or PCF component.
2. **Apply the corresponding checklist** from sections 2–5 above.
3. **Scan for CRITICAL issues first** — security vulnerabilities, data loss risks, and runtime crashes take priority.
4. **Document all findings** using the severity classification from section 1.
5. **Format the output** using the template from section 6.
6. **Provide actionable fixes** — every CRITICAL and HIGH finding must include a concrete code fix or remediation step.
7. **Summarize recommendations** — give the developer a prioritized action list so they know what to fix first.
