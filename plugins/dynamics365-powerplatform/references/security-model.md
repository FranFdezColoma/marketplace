# Security Model for Dynamics 365 & Power Platform

## Security Layers

```
[Environment-level access]
  └── [Business Unit hierarchy]
        └── [Security Roles]
              └── [Teams (Owner/Access)]
                    └── [Record-level sharing]
                          └── [Column-level security]
```

---

## Business Units (BU)

- Every user belongs to exactly one BU
- Parent BUs can access child BU data (with appropriate depth)
- BU hierarchy should reflect **data access needs**, NOT org chart

| Pattern | When |
|---------|------|
| Single BU | Small org, all see all |
| Regional BUs | Data segregation by geography |
| Departmental BUs | Segregation by function |
| Multi-tenant | Different customers/brands share environment |

Rules: max 3-4 levels; don't mirror org chart; root BU holds system accounts; plan for user transfers.

---

## Security Roles

### Structure
```
[Base Role]         → Minimum for app login
[Functional Role]   → Table CRUD by job function
[Elevated Role]     → Manager/admin overrides
```

### Privilege Depths

| Depth | Scope |
|-------|-------|
| None | No access |
| User | Own records only |
| Business Unit | Same BU records |
| Parent-Child BU | Same + child BU records |
| Organization | All records |

### Naming: `[Module] - [Level]`
Examples: `CRM - Base User`, `Sales - Representative`, `Sales - Manager`, `Service - Agent`

### Rules
1. Least privilege: start with minimum, add as needed
2. Additive: roles combined (union of privileges)
3. Never clone System Administrator — create specific elevated roles
4. Assign Base + Functional role(s)
5. Audit role assignments quarterly

---

## Teams

| Type | Owns Records | Use Case |
|------|-------------|----------|
| Owner Team | Yes | Share record ownership; roles assigned to team |
| Access Team | No | Per-record collaboration (template-based, dynamic) |
| Azure AD Group Team | Yes | Auto-sync from Entra ID; roles apply to all members |

---

## Record-Level Security (Sharing)

| Method | When |
|--------|------|
| Manual sharing | Ad-hoc access to specific records |
| Automatic (plugin/flow) | Condition-based access grants |
| Team sharing | Multiple users need same record access |
| Hierarchical | Managers see direct reports' records |

Privileges: Read, Write, Append, AppendTo, Assign, Share, Delete.

**Performance**: Excessive sharing bloats POA table → prefer role-based access. Monitor POA size.

---

## Column-Level Security

**Use for**: PII, salary, medical data, PCI-DSS compliance.

Steps: Create Field Security Profile → Add columns → Set permissions (Read/Update/Create) → Assign users/teams.

Rules: use sparingly (performance/UX impact); group related sensitive columns; test impact on views/reports/integrations.

---

## Application Users (S2S)

Non-interactive identities for integrations. Auth via Client ID + Secret/Certificate.

**Use for**: Azure Functions → Dataverse, Logic Apps, scheduled processes, third-party integrations.

### Setup
1. Register App Registration in Entra ID
2. Create Application User in Power Platform Admin Center
3. Assign Security Role
4. Use Client Credentials for auth

### Security Rules

| Rule | Implementation |
|------|---------------|
| Least privilege | Never System Administrator |
| Certificate auth | Prefer over client secret in production |
| Secret rotation | Before expiration (max 24 months) |
| Dedicated per integration | One Application User per external system |
| Non-interactive | Cannot login to UI |
| Monitor | Audit operations via audit log |

### Pattern: Azure Function → Dataverse
```
Azure Function → Entra ID (token) → Dataverse Web API
  App Registration: Client ID + Certificate
  Application User: Custom Integration Role (BU-level)
```

---

## Common Security Patterns

### Sales Team Isolation
```
BU: Region A, Region B
Roles: Sales Rep (User-level) | Manager (BU-level) | VP (Parent-Child BU)
```

### Service Desk Tiers
```
BU: Single BU (all agents)
Roles: Agent (User-level) | Senior (BU-level)
Teams: Tier 1 Queue (owns unassigned) | Tier 2 Queue (owns escalated)
```

### External Portal
```
BU: External Users BU (isolated)
Roles: Portal User (User-level, own only) | Portal Admin (BU-level within External)
```

---

## Anti-Patterns

1. System Administrator for regular users
2. Organization-level everything (only for truly global data)
3. Security through hiding (hidden tab ≠ secure — API still accessible)
4. Single mega-role (use modular, composable roles)
5. Ignoring API access (SDK bypasses UI restrictions)
6. No audit trail on sensitive entities
7. Sharing everything (POA bloat → performance)
8. Not testing with actual user credentials

---

## Auditing

Enable for: sensitive data tables, role changes, user access changes, deletions, bulk operations.

Retention: configure log retention (default 30 days); export to Azure Data Lake for compliance.
