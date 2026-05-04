---
name: jira-issue-creator
description: Create Jira issues with proper context for Dynamics 365 and Power Platform projects. Inspects existing issues to avoid duplicates. Creates test cases in Cucumber/Gherkin format. Uses the Atlassian MCP if available, otherwise generates issue content for manual creation.
---

# Jira Issue Creator for D365/Power Platform

Create well-structured Jira issues. Checks for duplicates before creation. Follows standardized templates per issue type.

---

## MCP Integration

**With Atlassian MCP**: Use `jira_search` (duplicates), `jira_get_issue` (context), `jira_create_issue`, `jira_create_issue_link`.

**Without MCP**: Generate complete issue content (summary, description, type, priority, labels, components) for manual copy.

---

## Workflow

1. Search duplicates: `project = [KEY] AND summary ~ "[keywords]" AND status != Done ORDER BY created DESC`
2. If duplicates found → present to user for confirmation
3. Gather: project key, type, priority, summary, description, labels, component
4. Create (MCP) or output formatted content

---

## Issue Templates

### Bug

**Summary**: `[Entity/Component] - [Brief description]`

```markdown
## Environment
- Environment: [Dev/QA/UAT/Prod]
- App: [Model-driven app name]
- User role: [Security role]

## Steps to Reproduce
1. [step]

## Expected Behavior
## Actual Behavior
## Impact
## Additional Context (error messages, trace logs, screenshots)

Labels: bug, d365, [component]
```

### Story

**Summary**: `[User role] - [Action/Capability]`

```markdown
## User Story
As a [role], I want to [action], So that [value].

## Acceptance Criteria
- [ ] AC1
- [ ] AC2

## Technical Notes
- Approach: [OOB/Low-Code/Pro-Code]
- Affected tables: [list]
- Security: [considerations]

## Out of Scope

Labels: story, d365, [module]
Story Points: [estimate]
```

### Task

**Summary**: `[Action verb] - [What]`

```markdown
## Objective
## Steps
1. ...

## Definition of Done
- [ ] [criterion]
- [ ] Code reviewed
- [ ] Deployed to [env]

## Dependencies

Labels: task, d365, [area]
```

### Epic

**Summary**: `[Business capability]`

```markdown
## Overview
## Business Value
## Scope (In/Out)
## Success Criteria
## Stories
- [ ] Story 1
- [ ] Story 2

Labels: epic, d365, [module]
```

---

## Test Case Format (MANDATORY)

When issue type is **Test Case**, this format is **REQUIRED**:

| Property | Value |
|----------|-------|
| Type | Automated |
| Framework | Cucumber |
| Format | Gherkin |

### Template

```gherkin
Feature: [Feature Name]
  [Brief feature description]

  Background:
    Given [common precondition]

  Scenario: [Descriptive scenario name]
    Given [initial context]
    When [action]
    Then [expected outcome]

  Scenario Outline: [Parameterized name]
    Given [context with <parameter>]
    When [action with <input>]
    Then [outcome with <expected>]

    Examples:
      | parameter | input | expected |
      | value1    | data1 | result1  |
```

### Gherkin Rules
- Feature name = business capability being tested
- Scenario name = intent, not steps
- Given = past/present state | When = single action | Then = expected outcome
- Background for shared preconditions | Scenario Outline for data-driven tests
- Naming: `When [context/action] Then [expected result]`

**Labels**: test-case, automated, cucumber, d365, [module] | **Component**: QA

---

## Labels

**Technology**: d365 | power-platform | dataverse | plugin | web-resource | pcf | power-automate | canvas-app | model-driven | azure

**Type**: bug | story | task | test-case | automated | cucumber | tech-debt
