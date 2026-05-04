# Solution Management Best Practices

## Solution Layering

```
[Active/Unmanaged Layer]    ← Direct customizations (avoid in prod)
[Managed Solution C]        ← Last imported wins for conflicts
[Managed Solution B]
[Managed Solution A]
[System Solution]           ← Microsoft base
```

### Segmentation

| Solution | Contents |
|----------|----------|
| `[Pub]Core` | Shared tables, global choices, security roles, site maps |
| `[Pub]Sales` | Sales-specific customizations |
| `[Pub]Service` | Service-specific customizations |
| `[Pub]Integration` | Custom APIs, plugins for external systems |
| `[Pub]Reporting` | Dashboards, charts, reports |

Rules: No circular dependencies. Base imported first. One component = one solution. Thin base, fat modules.

---

## Publisher Configuration

| Property | Rule |
|----------|------|
| Name | Lowercase, no spaces (e.g., `contoso`) |
| Prefix | 3-5 lowercase chars (e.g., `con`) — **CANNOT be changed after creation** |
| Choice Value Prefix | 5-digit number (e.g., `10000`) |

---

## Managed vs. Unmanaged

| Environment | Solution Type | Why |
|-------------|--------------|-----|
| Dev | Unmanaged | Allows editing |
| QA/UAT/Prod | Managed | Prevents accidental changes |

Workflow: Dev (unmanaged) → Export as managed → Import managed into QA/UAT/Prod.
Source control: Unmanaged solution files (unpacked).

Managed Properties control what consumers can customize: `CanModify`, `CanDelete`, form field additions.

---

## ALM Repository Structure

```
/src
├── Solutions/
│   ├── CoreSolution/src/
│   ├── SalesSolution/src/
│   └── IntegrationSolution/src/
├── Plugins/
│   ├── [Namespace].Plugins/
│   └── [Namespace].Plugins.Tests/
├── WebResources/
│   ├── src/
│   └── tests/
└── Pipelines/
    ├── build.yml
    └── release.yml
```

Pipeline: `[Commit] → [Build] → [Test] → [Pack] → [Deploy QA] → [Approve] → [Deploy Prod]`

---

## PAC CLI Commands

```powershell
pac solution clone --name [Name] --outputDirectory ./src
pac solution unpack --zipfile [solution.zip] --folder ./src --processCanvasApps
pac solution pack --folder ./src --zipfile [solution.zip] --packageType Managed
pac solution import --path [solution.zip] --environment [env-url]
pac solution export --name [Name] --path [output.zip] --managed
pac solution check --path [solution.zip] --geo [geo] --rule-set solution-checker
pac solution list --environment [env-url]
```

> `pac solution check` = static analysis (best practices, deprecated APIs). Does NOT validate import compatibility. For import issues, check Power Platform Admin Center or ImportJob entity.

---

## Environment Strategy

| Environment | Purpose | Solution Type |
|-------------|---------|---------------|
| Dev | Development | Unmanaged |
| Build | CI/CD automation | Managed |
| QA | Testing | Managed |
| UAT | User acceptance | Managed |
| Pre-Prod | Final validation | Managed |
| Production | Live | Managed |

Environment variables per env:

| Variable | Dev | QA | Prod |
|----------|-----|-----|------|
| API Endpoint | dev.api.com | qa.api.com | api.com |
| Feature Flag | true | true | false |
| Log Level | Debug | Info | Warning |

---

## Import/Export

### Pre-Import Checklist
- All dependencies imported in target
- Connection references have valid connections
- Environment variables have target-specific values
- No conflicting active unmanaged customizations
- Backup current state

### Import Order
1. Base/Core first → 2. Modules in dependency order → 3. Patches last

### Post-Import Validation
- Flows activated, plugin steps registered, security roles applied
- Customizations published, forms load, views return data, integrations work

---

## Version Strategy

```
Major.Minor.Build.Revision → 1.0.0.0 (initial), 1.1.0.0 (features), 1.1.1.0 (bugfix), 2.0.0.0 (breaking)
```

| Change | Increment |
|--------|-----------|
| New table/column | Minor |
| Plugin behavior change / bug fix | Build |
| Schema-breaking / rename / delete | Major |

---

## Common Pitfalls

1. Unmanaged customizations in Production
2. Two solutions modifying same form section
3. Missing dependencies on export
4. Connection references not configured in target
5. Skipping environments (Dev → Prod directly)
6. No rollback plan (keep previous version)
7. Not running `pac solution check` before deployment
