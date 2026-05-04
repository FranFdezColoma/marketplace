---
name: doc-generator
description: Generate standardized documentation for Dynamics 365 and Power Platform projects. Produces Technical Design Documents, Solution Design Documents, Deployment Guides, Release Notes, and other project documentation from templates.
---

# Documentation Generator for D365/Power Platform

Generate standardized documentation for D365 CE and Power Platform projects using the templates below.

---

## 1. Technical Design Document (TDD)

Trigger: "Create a TDD for [feature/component]"

```markdown
# Technical Design Document: [Feature Name]

| Property | Value |
|----------|-------|
| Version | 1.0 |
| Status | Draft |
| Author | [Author] |
| Date | [YYYY-MM-DD] |

## 1. Overview
### 1.1 Purpose
### 1.2 Scope (In/Out)
### 1.3 References (docs, Jira tickets)

## 2. Current State

## 3. Proposed Solution

### 3.1 High-Level Design
### 3.2 Dataverse Schema Changes
| Table | Column | Type | Purpose |
|-------|--------|------|---------|

### 3.3 Plugin Design
| Plugin | Message | Stage | Entity | Description |
|--------|---------|-------|--------|-------------|

### 3.4 Web Resource Changes
| File | Type | Purpose |
|------|------|---------|

### 3.5 Flow Design
| Flow Name | Trigger | Purpose |
|-----------|---------|---------|

### 3.6 Security Configuration
| Role | Table | Privileges | Scope |
|------|-------|-----------|-------|

## 4. Data Migration
## 5. Integration Points
## 6. Performance Considerations

## 7. Testing Strategy
| Test Type | Scope | Tool |
|-----------|-------|------|
| Unit | Plugins | MSTest + Moq |
| Unit | JS | Vitest + xrm-mock |
| Integration | Flows | Power Automate Test |
| UAT | E2E | Manual |

## 8. Deployment Plan
## 9. Rollback Plan
## 10. Open Questions
| # | Question | Owner | Status |
|---|----------|-------|--------|
```

---

## 2. Solution Design Document (SDD - Lightweight)

> For comprehensive SDD with Mermaid diagrams and phased approach, use the **solution-design** skill.

```markdown
# Solution Design Document: [Solution Name]

| Property | Value |
|----------|-------|
| Version | 1.0 |
| Status | Draft |
| Author | [Author] |
| Date | [YYYY-MM-DD] |

## 1. Executive Summary
## 2. Business Requirements
| ID | Requirement | Priority | Source |
|----|------------|----------|--------|

## 3. Solution Overview
### 3.1 Architecture Diagram
### 3.2 Technology Stack
| Component | Technology | Justification |
|-----------|-----------|---------------|

### 3.3 Solution Components
| Component | Type | Solution |
|-----------|------|----------|

## 4. Detailed Design (per feature)
## 5. Integration Architecture
## 6. Security Design
## 7. Environment Strategy
| Environment | Purpose | URL |
|-------------|---------|-----|

## 8. ALM Strategy
## 9. Non-Functional Requirements
| Category | Requirement | Target |
|----------|------------|--------|

## 10. Assumptions and Constraints
## 11. Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
```

---

## 3. Deployment Guide

Trigger: "Create a deployment guide for [solution/release]"

```markdown
# Deployment Guide: [Solution/Release Name]

| Property | Value |
|----------|-------|
| Version | 1.0 |
| Date | [YYYY-MM-DD] |
| Target | [Environment] |

## Prerequisites
- [ ] Admin access to target environment
- [ ] Solution files available
- [ ] Connection references configured
- [ ] Environment variables set

## Pre-Deployment
- [ ] Backup existing solution (export managed)
- [ ] Notify affected users
- [ ] Verify environment health

## Deployment Steps

### Step 1: Import Solution

    pac solution import --path [solution.zip] --environment [env-url]

### Step 2: Configure Connection References
| Connection Reference | Connector | Instructions |
|---------------------|-----------|--------------|

### Step 3: Set Environment Variables
| Variable | Prod | UAT |
|----------|------|-----|

### Step 4: Activate Flows
### Step 5: Publish Customizations

    pac solution publish

## Post-Deployment Verification
- [ ] Forms load correctly
- [ ] Key business processes work
- [ ] Integrations active
- [ ] Flow run history clean
- [ ] Security roles correct

## Rollback
1. Deactivate new flows
2. Import previous solution backup
3. Revert data changes
4. Notify stakeholders
```

---

## 4. Release Notes

Trigger: "Create release notes for version [X.Y.Z]"

```markdown
# Release Notes: v[X.Y.Z]

**Date**: [YYYY-MM-DD] | **Environment**: [Target]

## Summary

## New Features
| Feature | Description | Jira |
|---------|-------------|------|

## Improvements
| Improvement | Description | Jira |
|-------------|-------------|------|

## Bug Fixes
| Bug | Description | Root Cause | Jira |
|-----|-------------|-----------|------|

## Configuration Changes
| Change | Details | Action Required |
|--------|---------|----------------|

## Breaking Changes
## Known Issues
| Issue | Impact | Workaround | Target Fix |
|-------|--------|-----------|-----------|

## Dependencies
## Deployment Notes
```

---

## 5. Change Request

Trigger: "Create a change request for [change]"

```markdown
# Change Request: [CR-XXX]

| Property | Value |
|----------|-------|
| Title | [Change Title] |
| Priority | [High/Medium/Low] |
| Requester | [Name] |
| Date | [YYYY-MM-DD] |

## Change Description
## Business Justification

## Impact Analysis
### Affected Components
| Component | Impact |
|-----------|--------|

### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|

## Implementation Plan
## Testing Plan
## Rollback Plan

## Approvals
| Approver | Role | Status | Date |
|----------|------|--------|------|
```

---

## Guidelines

- Always gather context (project, audience, purpose) before generating
- Replace ALL placeholders with actual data
- Use consistent terminology (see documenter agent's terminology table)
- Include metadata header on every document
