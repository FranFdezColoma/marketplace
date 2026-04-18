# arc42 Architecture Documentation Template

> arc42 section skeleton for Dynamics 365 / Power Platform projects.
> Replace `{placeholders}` with project-specific content.

---

## 1. Introduction and Goals

### 1.1 Requirements Overview
{Describe the key business requirements driving this project.}

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| R1 | {requirement} | {High/Medium/Low} | {description} |

### 1.2 Quality Goals
| Priority | Quality Attribute | Description |
|----------|-------------------|-------------|
| 1 | {attribute} | {goal} |
| 2 | {attribute} | {goal} |
| 3 | {attribute} | {goal} |

### 1.3 Stakeholders
| Role | Name/Team | Expectations | Influence |
|------|-----------|--------------|-----------|
| {role} | {name} | {expectations} | {High/Medium/Low} |

---

## 2. Architecture Constraints

### 2.1 Technical Constraints
| ID | Constraint | Description |
|----|-----------|-------------|
| TC1 | {constraint} | {description} |

### 2.2 Organizational Constraints
| ID | Constraint | Description |
|----|-----------|-------------|
| OC1 | {constraint} | {description} |

### 2.3 Convention Constraints
| ID | Constraint | Description |
|----|-----------|-------------|
| CC1 | {constraint} | {description} |

---

## 3. System Scope and Context

### 3.1 Business Context
{Mermaid C4Context diagram here}

| Actor/System | Description | Input | Output |
|-------------|-------------|-------|--------|
| {actor} | {description} | {input} | {output} |

### 3.2 Technical Context
| Interface | Technology | Protocol | Description |
|-----------|-----------|----------|-------------|
| {interface} | {technology} | {protocol} | {description} |

---

## 4. Solution Strategy

### 4.1 Technology Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| {decision} | {choice} | {rationale} |

### 4.2 OOB vs. Low Code vs. Pro Code
| Capability | Approach | Justification |
|-----------|----------|---------------|
| {capability} | {OOB/Low Code/Pro Code} | {justification} |

### 4.3 Solution Layering
| Solution | Type | Purpose | Dependencies |
|----------|------|---------|-------------|
| {solution} | {Managed/Unmanaged} | {purpose} | {dependencies} |

---

## 5. Building Block View

### 5.1 Level 1 — System Overview
{Mermaid diagram showing overall decomposition}

| Building Block | Description | Technology |
|---------------|-------------|-----------|
| {block} | {description} | {technology} |

### 5.2 Level 2 — Solution Decomposition
| Component | Type | Description |
|-----------|------|-------------|
| {component} | {Plugin/Flow/PCF/etc.} | {description} |

### 5.3 Level 3 — Component Detail
{Detailed view of individual components — add as needed.}

---

## 6. Runtime View

### 6.1 {Scenario Name}
{Mermaid sequence diagram here}

### 6.2 Plugin Execution Pipeline
| Step | Stage | Entity | Message | Mode | Description |
|------|-------|--------|---------|------|-------------|
| {step} | {stage} | {entity} | {message} | {Sync/Async} | {description} |

---

## 7. Deployment View

### 7.1 Environment Topology
{Mermaid deployment diagram here}

| Environment | Type | Purpose | URL |
|------------|------|---------|-----|
| DEV | Sandbox | Development | {url} |
| TEST | Sandbox | Testing | {url} |
| UAT | Sandbox | Acceptance | {url} |
| PROD | Production | Live | {url} |

### 7.2 Deployment Pipeline
| Step | Action | Tool | Trigger |
|------|--------|------|---------|
| {step} | {action} | {tool} | {trigger} |

---

## 8. Cross-cutting Concepts

### 8.1 Security Model
| Role | Base Role | Scope | Description |
|------|-----------|-------|-------------|
| {role} | {base} | {scope} | {description} |

### 8.2 Error Handling
| Layer | Strategy | Implementation |
|-------|----------|---------------|
| {layer} | {strategy} | {details} |

### 8.3 Logging and Monitoring
| What | Tool | Details |
|------|------|---------|
| {what} | {tool} | {details} |

### 8.4 Data Migration
| Source | Target | Method | Volume |
|--------|--------|--------|--------|
| {source} | {target} | {method} | {volume} |

## 9. Architecture Decisions

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-001 | {title} | {Proposed/Accepted/Deprecated} | {date} |

## 10. Quality Requirements

### 10.1 Quality Tree
| Category | Quality Attribute | Target |
|----------|-------------------|--------|
| {category} | {attribute} | {target} |

### 10.2 Quality Scenarios
| ID | Quality Attribute | Scenario | Measure | Priority |
|----|-------------------|----------|---------|----------|
| QS-01 | {attribute} | {scenario} | {measure} | {priority} |

## 11. Risks and Technical Debt

### 11.1 Risks
| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R-01 | {risk} | {High/Medium/Low} | {High/Medium/Low} | {mitigation} |

### 11.2 Technical Debt
| ID | Description | Impact | Effort | Priority |
|----|-------------|--------|--------|----------|
| TD-01 | {description} | {impact} | {S/M/L/XL} | {priority} |

## 12. Glossary

| Term | Definition |
|------|-----------|
| {term} | {definition} |

| Abbreviation | Full Form |
|-------------|-----------|
| D365 | Dynamics 365 |
| PP | Power Platform |
| OOB | Out of the Box |
| PCF | PowerApps Component Framework |
| BU | Business Unit |
