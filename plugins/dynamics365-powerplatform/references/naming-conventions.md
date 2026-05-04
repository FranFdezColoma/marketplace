# Naming Conventions for Dynamics 365 & Power Platform

## Table (Entity)

| Rule | Example |
|------|---------|
| Publisher prefix | `contoso_` |
| Singular nouns | `contoso_project` (not `projects`) |
| PascalCase display name | "Project Task" |
| Lowercase logical name | `contoso_projecttask` |
| Max 50 chars (logical) | — |
| No abbreviations | `contoso_invoice` (not `inv`) |

- Standard tables: use as-is (account, contact, opportunity, incident)
- Custom tables: always publisher prefix
- N:N intersect tables: auto-generated, don't rename

---

## Column (Field/Attribute)

| Rule | Example |
|------|---------|
| Publisher prefix | `contoso_projectname` |
| Lowercase logical name | `contoso_estimatedcost` |
| PascalCase display name | "Estimated Cost" |
| No type suffix in logical name | `contoso_amount` (not `amountmoney`) |
| Descriptive names | `contoso_approvalstatus` (not `status1`) |

---

## Solution

| Component | Pattern | Example |
|-----------|---------|---------|
| Publisher | Company abbreviation | `contoso` |
| Prefix | 3-5 char lowercase | `con` |
| Base solution | `[Publisher]Core` | `ContosoCore` |
| Module solutions | `[Publisher][Module]` | `ContosoSales` |
| Patch | `[Solution]_Patch_[YYYYMMDD]` | `ContosoSales_Patch_20240115` |
| Version | Major.Minor.Build.Revision | `1.2.0.0` |

```
ContosoCore          (shared tables, security roles, site maps)
├── ContosoSales     (sales customizations)
├── ContosoService   (service customizations)
└── ContosoPortal    (portal components)
```

---

## Plugin

| Component | Pattern | Example |
|-----------|---------|---------|
| Namespace | `[Company].[Project].Plugins` | `Contoso.CRM.Plugins` |
| Assembly | Same as namespace | `Contoso.CRM.Plugins.dll` |
| Class | `[Message][Entity]Handler` | `CreateAccountHandler` |
| Step name | `[Assembly].[Class]: [Stage] [Message] of [Entity]` | `Contoso.CRM.Plugins.CreateAccountHandler: Pre-operation Create of account` |

---

## Web Resource

| Pattern | Example |
|---------|---------|
| `[prefix]_/scripts/[entity]/[purpose].js` | `contoso_/scripts/account/onload.js` |
| `[prefix]_/styles/[component].css` | `contoso_/styles/customgrid.css` |
| `[prefix]_/html/[page].html` | `contoso_/html/dashboard.html` |

```javascript
var Contoso = Contoso || {};
Contoso.Account = Contoso.Account || {};
Contoso.Account.OnLoad = function(executionContext) { ... };

if (typeof module !== "undefined" && module.exports) {
    module.exports = { OnLoad: Contoso.Account.OnLoad };
}
```

---

## Power Automate Flow

| Pattern | Example |
|---------|---------|
| `[prefix]_[Entity]_[Trigger]_[Purpose]` | `contoso_Case_OnCreate_AssignToQueue` |
| Scheduled | `contoso_DataSync_Daily` |
| Manual | `contoso_ExportReport_Manual` |
| Child | `contoso_SendNotification_Child` |

---

## Environment Variable

| Pattern | Example |
|---------|---------|
| `[prefix]_[Category]_[Name]` | `contoso_Integration_ApiBaseUrl` |
| Boolean flags | `contoso_Feature_EnableAudit` |

---

## Connection Reference

| Pattern | Example |
|---------|---------|
| `[prefix]_[Connector]_[Purpose]` | `contoso_Dataverse_MainConnection` |

---

## PCF Control

| Component | Pattern | Example |
|-----------|---------|---------|
| Namespace | `[Company].Controls` | `Contoso.Controls` |
| Control name | PascalCase | `RatingStars` |
| Solution | `[Prefix][Control]PCF` | `ContosoRatingStarsPCF` |

---

## Custom API

| Pattern | Example |
|---------|---------|
| `[prefix]_[Verb][Noun]` | `contoso_CalculateDiscount` |
| Verbs | Calculate, Validate, Process, Generate, Get, Set, Send, Sync |

---

## Security Role

| Pattern | Example |
|---------|---------|
| `[Module] - [Level]` | `Sales - Manager` |
| Base | `CRM - Base User` |
| Admin | `CRM - Administrator` |

---

## General Rules

1. Consistency: one pattern applied everywhere
2. No spaces in logical names (use concatenation)
3. English for technical names (even non-English implementations)
4. Avoid reserved words without prefix (`status`, `state`, `type`)
5. Prefix all custom components (prevents import conflicts)
6. Max length awareness per component type
