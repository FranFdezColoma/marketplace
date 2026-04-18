---
name: jira-issue-creator
description: 'Create Jira or Azure DevOps work items following agile best practices. Supports User Stories, Tasks, Bugs, Epics, and Test Cases. Test Cases use Gherkin/Cucumber syntax. Integrates with Jira MCP for direct issue creation when available.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: workflow
  stack: dynamics365-powerplatform
---

# Jira / Azure DevOps Work Item Creator

Create well-structured work items following agile best practices. Supports Epics, User Stories, Tasks, Bugs, and Test Cases. Test Cases always use Gherkin/Cucumber syntax. Integrates with Jira MCP tools for direct issue creation when available.

---

## Supported Work Item Types

### 1. Epic

Large feature or initiative containing multiple User Stories.

**Template:**

```
Title: [EPIC] {Feature Name}

Description:
{High-level description of the feature or initiative.}

Acceptance Criteria:
- {business outcome 1}
- {business outcome 2}
- {business outcome 3}

Business Value:
{Why this matters to the business. Quantify impact if possible.}

Target Release: {version or sprint range}
Priority: {Critical | High | Medium | Low}
Labels: {module, component}
```

**Example:**

```
Title: [EPIC] Customer 360 View

Description:
Implement a unified Customer 360 view in Dynamics 365 Sales that consolidates
customer interactions, purchase history, support tickets, and engagement metrics
into a single dashboard accessible from the Account form.

Acceptance Criteria:
- Sales reps can view all customer interactions from one screen
- Data refreshes within 5 minutes of source system updates
- Dashboard loads in under 3 seconds

Business Value:
Reduce time-to-insight for sales reps by 40%, improving close rates and
customer satisfaction scores.

Target Release: v2.0 — Sprint 8-12
Priority: High
Labels: sales, dashboard, integration
```

---

### 2. User Story

User-facing functionality written from the perspective of the end user.

**Template:**

```
Title: As a {role}, I want {goal} so that {benefit}

Description:

## Context
{Background information explaining why this story exists.}

## Acceptance Criteria
- GIVEN {precondition} WHEN {action} THEN {expected result}
- GIVEN {precondition} WHEN {action} THEN {expected result}
- GIVEN {precondition} WHEN {action} THEN {expected result}

## Technical Notes
- {implementation hints or constraints}
- {relevant Dataverse tables, plugins, or flows}

## Out of Scope
- {what this story does NOT include}

Story Points: {estimation}
Priority: {Critical | High | Medium | Low}
Labels: {component labels}
```

---

### 3. Task

Technical task, often a child of a User Story.

**Template:**

```
Title: {Action verb} {what needs to be done}

Description:

## Objective
{What needs to be accomplished and why.}

## Steps
1. {step 1}
2. {step 2}
3. {step 3}

## Definition of Done
- [ ] Code implemented
- [ ] Unit tests passing (>80% coverage)
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Tested in DEV environment
- [ ] No SonarQube blocker/critical issues

Estimation: {hours or story points}
Parent: {parent story key, if applicable}
Labels: {component labels}
```

---

### 4. Bug

Defect report with reproducible steps.

**Template:**

```
Title: [BUG] {Short description of the defect}

Description:

## Environment
- Environment: {Dev | Test | UAT | Production}
- Browser/Client: {if applicable}
- User role: {security role}
- D365 App: {Sales Hub | Customer Service Hub | Custom App}

## Steps to Reproduce
1. {step 1}
2. {step 2}
3. {step 3}

## Expected Behavior
{What should happen.}

## Actual Behavior
{What actually happens. Include error messages verbatim.}

## Evidence
{Screenshots, browser console logs, plugin trace logs, flow run URLs.}

## Impact
- Affected users: {who is impacted and how many}
- Workaround: {if any workaround exists, describe it}
- Data impact: {is data corrupted or lost?}

Priority: {Critical | High | Medium | Low}
Severity: {Blocker | Critical | Major | Minor | Trivial}
Labels: {component, environment}
```

**Example:**

```
Title: [BUG] Opportunity close plugin fails with NullReferenceException when account has no primary contact

Description:

## Environment
- Environment: Test
- Browser/Client: Edge 120
- User role: Sales Representative
- D365 App: Sales Hub

## Steps to Reproduce
1. Create a new Account without setting a Primary Contact
2. Create an Opportunity linked to that Account
3. Navigate to the Opportunity and click "Close as Won"
4. Fill in the close dialog and click OK

## Expected Behavior
The opportunity should close successfully regardless of whether the account has a primary contact.

## Actual Behavior
Error dialog: "An error has occurred. Please contact your system administrator."
Plugin trace log shows: System.NullReferenceException at OnOpportunityClose.Execute() line 47

## Evidence
- Plugin trace log attached (trace_20240115.txt)
- Screenshot of error dialog attached

## Impact
- Affected users: All sales reps closing opportunities on accounts without primary contacts (~15% of accounts)
- Workaround: Set a dummy primary contact on the account before closing
- Data impact: None — the close operation is rolled back

Priority: High
Severity: Critical
Labels: plugin, sales, opportunity
```

---

### 5. Test Case (Gherkin/Cucumber Syntax)

Test cases MUST use Gherkin syntax for clear, structured, and automatable scenarios. Always include happy path, edge cases, and error cases.

**Template:**

```
Title: [TC] {Feature} — {Scenario description}

Description:

## Feature: {Feature Name}
{Brief feature description.}

### Scenario: {Happy Path Scenario Name}

```gherkin
Given {precondition / initial state}
  And {additional precondition}
When {action performed by user}
  And {additional action}
Then {expected outcome}
  And {additional expected outcome}
```

### Scenario: {Edge Case Scenario Name}

```gherkin
Given {precondition}
When {action}
Then {expected outcome}
```

### Scenario: {Error Case Scenario Name}

```gherkin
Given {precondition}
When {invalid action}
Then {error handling outcome}
  And {user-friendly message is displayed}
```

### Scenario Outline: {Parameterized Scenario Name}

```gherkin
Given the user has role <role>
When the user performs <action>
Then the result should be <expected_result>

Examples:
| role          | action        | expected_result |
| {role 1}      | {action 1}    | {result 1}      |
| {role 2}      | {action 2}    | {result 2}      |
| {role 3}      | {action 3}    | {result 3}      |
```

## Test Data
{Required test data setup — records, roles, configuration.}

## Preconditions
{Environment setup, user roles, data requirements.}

Priority: {Critical | High | Medium | Low}
Labels: {feature, regression, smoke, etc.}
```

**Example:**

```
Title: [TC] Opportunity Validation — Amount exceeds approved budget

Description:

## Feature: Opportunity Amount Validation
When a sales rep updates an opportunity's estimated value, the system validates
that it does not exceed the parent account's approved budget.

### Scenario: Amount within budget

```gherkin
Given an Account "Contoso Ltd" with approved budget of $100,000
  And an Opportunity "Contoso Deal" linked to "Contoso Ltd" with estimated value $50,000
When the sales rep updates the estimated value to $90,000
Then the Opportunity is saved successfully
  And no error message is displayed
```

### Scenario: Amount exceeds budget

```gherkin
Given an Account "Contoso Ltd" with approved budget of $100,000
  And an Opportunity "Contoso Deal" linked to "Contoso Ltd" with estimated value $50,000
When the sales rep updates the estimated value to $150,000
Then the save is blocked
  And an error message is displayed: "Estimated value exceeds the approved budget of $100,000"
```

### Scenario: Account has no approved budget set

```gherkin
Given an Account "Northwind" with no approved budget configured
  And an Opportunity "Northwind Deal" linked to "Northwind"
When the sales rep sets the estimated value to any amount
Then the Opportunity is saved successfully
```

### Scenario Outline: Role-based validation behavior

```gherkin
Given an Account with approved budget of $100,000
  And an Opportunity linked to the Account
  And the user has role <role>
When the user updates estimated value to <amount>
Then the result should be <expected_result>

Examples:
| role          | amount   | expected_result                       |
| Sales Manager | $150,000 | Save succeeds (managers can override) |
| Sales Rep     | $150,000 | Save blocked with error message       |
| Sales Rep     | $90,000  | Save succeeds                         |
```

## Test Data / Preconditions
- Accounts with/without approved budgets, linked Opportunities
- Users with different security roles (Sales Manager, Sales Rep, Read Only)
- Plugin registered and active in test environment

Priority: High
Labels: plugin, validation, regression
```

---

## Jira MCP Integration

When Jira MCP tools are available (`mcp-atlassian-jira_*`), use them for direct issue management:

### Creating Issues

```
1. Use `jira_search` to check for duplicate or related issues:
   JQL: "project = {KEY} AND summary ~ '{keywords}' AND status != Done"

2. Use `jira_create_issue` with the appropriate fields:
   - project_key: The project key (ask user if unknown)
   - summary: The title from the template
   - issue_type: Epic | Story | Task | Bug | Test
   - description: The full description in Markdown format
   - additional_fields: priority, labels, story points, parent link

3. Use `jira_create_issue_link` to link related issues:
   - "Blocks" — this issue blocks another
   - "is blocked by" — this issue is blocked by another
   - "Relates to" — general relationship
   - Parent link — for subtasks or stories under epics

4. Use `jira_link_to_epic` to associate stories/tasks with their epic.
```

### Issue Type Mapping

| Work Item Type | Jira Issue Type | Notes |
|---------------|----------------|-------|
| Epic | Epic | Use `epicKey` in additional_fields for child linking |
| User Story | Story | Map Story Points to the story points custom field |
| Task | Task | Link to parent Story via `parent` in additional_fields |
| Bug | Bug | Map Severity to custom field if available |
| Test Case | Test (or Task) | Depends on project configuration; use Task if Test type is unavailable |

### Batch Creation

When creating multiple related items (e.g., an Epic with Stories and Tasks):

```
1. Create the Epic first — capture the returned issue key
2. Create Stories linked to the Epic — capture their keys
3. Create Tasks as children of each Story
4. Create Test Cases for each Story's acceptance criteria
5. Link related items (blocks, relates-to)
```

Use `jira_batch_create_issues` for bulk creation when creating multiple independent items.

---

## Azure DevOps Format

When targeting Azure DevOps instead of Jira, adjust the terminology and fields:

### Field Mapping (Jira → Azure DevOps)

Epic→Epic, Story→PBI, Task→Task, Bug→Bug, Test Case→Test Case (Azure Test Plans), Story Points→Effort, Priority→Priority (1-4), Labels→Tags (semicolon-separated), Sprint→Iteration Path, Component→Area Path.

When targeting Azure DevOps, use Area Path + Iteration Path instead of Components + Sprints, and use the same structured descriptions/acceptance criteria as Jira templates.

---

## Workflow

1. **Gather info**: Ask for work item type, project key (use `jira_get_all_projects` if MCP available), requirement description, target platform (Jira/Azure DevOps).
2. **Decompose**: If too large for one Story, suggest Epic + Stories. Identify implied Tasks.
3. **Generate**: Use templates above. For Test Cases, ALWAYS use Gherkin. Include happy path, edge cases, error cases.
4. **Create**: If Jira MCP available, create directly via `jira_create_issue` and link with `jira_create_issue_link`. Otherwise, output formatted for manual creation.
5. **Review**: Present items, offer adjustments, suggest additional Test Cases if coverage is low.

---

## Best Practices

### Story Sizing
- Completable within one sprint (1-13 story points). Over 13 → decompose. Use INVEST criteria.

### Acceptance Criteria
- Every Story MUST have ≥2 criteria in GIVEN/WHEN/THEN format. Must be testable (no vague terms).

### Bug Reports
- Must be reproducible from Steps to Reproduce. Include exact error messages, environment, and evidence.

### Test Cases
- ALWAYS use Gherkin/Cucumber syntax — no exceptions.
- Cover: happy path, boundary values, negative cases, security (role-based, FLS).
- Use Scenario Outlines for parameterized tests.

### Labels
Use consistent labels: `plugin`, `flow`, `pcf`, `web-resource`, `model-driven`, `canvas-app`, `integration`, `data-migration`, `security`, `regression`, `smoke`, `critical-path`.

### D365/PP-Specific Considerations
- **Plugin Tasks**: Include registration details (stage, message, entity, mode).
- **Flow Tasks**: Specify trigger type, connectors, error handling.
- **PCF Tasks**: Control type (field/dataset), target entity, form placement.
- **Security Tasks**: BU hierarchy, role assignments, FLS profiles.
- **Test Cases**: Cover concurrent edits, async operations, offline scenarios.
