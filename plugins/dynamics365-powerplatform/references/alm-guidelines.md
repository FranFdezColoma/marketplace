# ALM Guidelines for Dynamics 365 & Power Platform

> Application Lifecycle Management best practices for D365 / Power Platform projects.
> Replace `{Publisher}` with your publisher name (e.g. `Contoso`) and `{prefix}_` with your prefix (e.g. `contoso_`).

---

## 1. Environment Strategy

### Recommended Environments

| Environment | Type | Purpose |
|---|---|---|
| **Development** | Sandbox | Active development — unmanaged solutions |
| **Build / CI** | Sandbox | Automated build validation (optional) |
| **Test / QA** | Sandbox | Manual and automated testing |
| **UAT** | Sandbox | User acceptance testing with production-like data |
| **Staging / Pre-prod** | Sandbox or Production | Final validation mirror of production |
| **Production** | Production | Live system |

### Key Decisions

| Decision | Guidance |
|---|---|
| **Individual vs shared dev** | Individual dev environments prevent conflicts; shared dev is cheaper but requires coordination |
| **Sandbox vs Production type** | Use **Sandbox** for all non-production environments. Only Production has full SLA and backup capabilities |
| **Data strategy** | Dev: minimal sample data. QA/UAT: anonymised copy of production data. Staging: production-like volume |
| **Refresh cadence** | Refresh QA/UAT from production quarterly or before major releases |

### Environment Diagram

```
Developer 1 ──┐
Developer 2 ──┼──► Build/CI ──► Test/QA ──► UAT ──► Staging ──► Production
Developer 3 ──┘
```

---

## 2. Solution Architecture

### 2.1 Segmented Solutions (Recommended)

Split solutions by **layer** to enable independent deployment and reduce merge conflicts.

| Solution | Contains |
|---|---|
| `{Publisher}Core` | Tables, columns, relationships, global choices |
| `{Publisher}Plugins` | Plugin assemblies, plugin step registrations |
| `{Publisher}Flows` | Cloud Flows, Business Rules, Business Process Flows |
| `{Publisher}UI` | Forms, views, dashboards, sitemap, app modules |
| `{Publisher}Security` | Security roles, field-level security profiles |
| `{Publisher}WebResources` | JavaScript, HTML, CSS, images |
| `{Publisher}PCF` | PCF control components |

> **Dependency order**: Core → Plugins / WebResources / Flows → UI → Security

### 2.2 Managed vs Unmanaged

| Environment | Solution Type | Why |
|---|---|---|
| Development | **Unmanaged** | Editable — developers can make changes |
| Test / QA | **Managed** | Locked — tests run against the exact artifact that goes to production |
| UAT | **Managed** | Users validate the managed solution |
| Staging | **Managed** | Final verification |
| Production | **Managed** | Clean install / uninstall; enforced layering |

> **Never** import unmanaged solutions into non-development environments.

### 2.3 Solution Layering

When multiple managed solutions modify the same component:

1. **Last one wins** — the most recently imported solution's customisation takes effect
2. **Active layer** — unmanaged customisations always sit on top (dev only)
3. Use **Solution Checker** to detect conflicts before import
4. Avoid overlapping components across solutions when possible

---

## 3. Source Control

### 3.1 Extracting Solutions to Source Control

```bash
# Clone solution into source-controlled folder structure
pac solution clone --name ContosoCore --outputDirectory ./solutions/ContosoCore

# Or export and unpack
pac solution export --name ContosoCore --path ./exports/ContosoCore.zip --managed false
pac solution unpack --zipfile ./exports/ContosoCore.zip --folder ./solutions/ContosoCore --packagetype Both
```

### 3.2 Recommended Git Folder Structure

```
repo-root/
├── solutions/
│   ├── ContosoCore/
│   │   ├── src/
│   │   │   ├── Entities/
│   │   │   ├── OptionSets/
│   │   │   ├── Other/
│   │   │   └── solution.xml
│   │   └── ContosoCore.cdsproj
│   ├── ContosoPlugins/
│   └── ContosoUI/
├── plugins/
│   ├── Contoso.Sales.Plugins/
│   │   ├── Contoso.Sales.Plugins.csproj
│   │   └── *.cs
│   └── Contoso.Sales.Plugins.Tests/
│       ├── Contoso.Sales.Plugins.Tests.csproj
│       └── *.cs
├── webresources/
│   ├── src/
│   │   ├── scripts/
│   │   ├── html/
│   │   └── css/
│   ├── tests/
│   └── package.json
├── pcf/
│   └── PhoneValidator/
│       ├── PhoneValidator/
│       │   └── index.ts
│       └── pcfproj
├── docs/
│   ├── adr/
│   └── architecture/
├── pipelines/
│   ├── azure-pipelines.yml
│   └── templates/
├── .gitignore
└── README.md
```

### 3.3 `.gitignore` for D365 Projects

```gitignore
# Build output
bin/
obj/
out/
*.dll
*.pdb

# NuGet
packages/

# Node
node_modules/
dist/

# Solution zip files
*.zip

# User-specific
*.user
*.suo
.vs/

# Environment-specific
.env
.env.local

# PCF generated
**/generated/
**/bundle.js
```

### 3.4 Branch Strategy

**Option A — GitFlow** (recommended for larger teams)

```
main            ← production-ready code
├── develop     ← integration branch
│   ├── feat/PROJ-123-new-feature
│   ├── fix/PROJ-456-bug-fix
│   └── refactor/PROJ-789-cleanup
├── release/v1.2.0   ← release candidate
└── hotfix/PROJ-999-critical-fix
```

**Option B — Trunk-Based** (recommended for small teams / continuous delivery)

```
main            ← always deployable
├── feat/PROJ-123-new-feature   (short-lived)
├── fix/PROJ-456-bug-fix        (short-lived)
└── hotfix/PROJ-999-critical    (short-lived)
```

---

## 4. CI/CD Pipelines

### 4.1 Build Pipeline (CI)

Triggered on every PR or push to integration branch.

```yaml
# azure-pipelines.yml — Build Pipeline
trigger:
  branches:
    include:
      - develop
      - main

pool:
  vmImage: 'windows-latest'

steps:
  # 1. Install Power Platform CLI
  - task: PowerPlatformToolInstaller@2
    displayName: 'Install Power Platform Tools'

  # 2. Build plugin assemblies
  - task: DotNetCoreCLI@2
    displayName: 'Build Plugins'
    inputs:
      command: 'build'
      projects: 'plugins/**/*.csproj'

  # 3. Run unit tests
  - task: DotNetCoreCLI@2
    displayName: 'Run Plugin Tests'
    inputs:
      command: 'test'
      projects: 'plugins/**/*.Tests.csproj'

  # 4. Pack solution from source
  - task: PowerPlatformPackSolution@2
    displayName: 'Pack Managed Solution'
    inputs:
      SolutionSourceFolder: 'solutions/ContosoCore/src'
      SolutionOutputFile: '$(Build.ArtifactStagingDirectory)/ContosoCore_managed.zip'
      SolutionType: 'Managed'

  # 5. Run Solution Checker
  - task: PowerPlatformChecker@2
    displayName: 'Solution Checker'
    inputs:
      authenticationType: 'PowerPlatformSPN'
      PowerPlatformSPN: 'BuildServiceConnection'
      FilesToAnalyze: '$(Build.ArtifactStagingDirectory)/ContosoCore_managed.zip'
      RuleSet: 'Solution Checker'

  # 6. Publish artifacts
  - task: PublishBuildArtifacts@1
    displayName: 'Publish Artifacts'
    inputs:
      PathtoPublish: '$(Build.ArtifactStagingDirectory)'
      ArtifactName: 'solutions'
```

### 4.2 Release Pipeline (CD)

Triggered after a successful build on `main` or manually.

```yaml
# release-pipeline.yml
stages:
  - stage: DeployToTest
    jobs:
      - deployment: ImportSolution
        environment: 'Test'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: PowerPlatformToolInstaller@2
                  displayName: 'Install Power Platform Tools'

                - task: PowerPlatformImportSolution@2
                  displayName: 'Import Managed Solution'
                  inputs:
                    authenticationType: 'PowerPlatformSPN'
                    PowerPlatformSPN: 'TestServiceConnection'
                    SolutionInputFile: '$(Pipeline.Workspace)/solutions/ContosoCore_managed.zip'
                    AsyncOperation: true
                    MaxAsyncWaitTime: 60

  - stage: DeployToUAT
    dependsOn: DeployToTest
    condition: succeeded()
    jobs:
      - deployment: ImportSolution
        environment: 'UAT'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: PowerPlatformToolInstaller@2
                - task: PowerPlatformImportSolution@2
                  inputs:
                    authenticationType: 'PowerPlatformSPN'
                    PowerPlatformSPN: 'UATServiceConnection'
                    SolutionInputFile: '$(Pipeline.Workspace)/solutions/ContosoCore_managed.zip'
                    AsyncOperation: true
                    MaxAsyncWaitTime: 60
```

### 4.3 GitHub Actions Alternative

```yaml
# .github/workflows/build.yml
name: Build & Validate Solution
on:
  pull_request:
    branches: [main, develop]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install PAC CLI
        uses: microsoft/powerplatform-actions/install-pac@v1

      - name: Build plugins
        run: dotnet build plugins/ --configuration Release

      - name: Run tests
        run: dotnet test plugins/ --configuration Release --no-build

      - name: Pack solution
        uses: microsoft/powerplatform-actions/pack-solution@v1
        with:
          solution-folder: solutions/ContosoCore/src
          solution-file: out/ContosoCore_managed.zip
          solution-type: Managed

      - name: Solution Checker
        uses: microsoft/powerplatform-actions/check-solution@v1
        with:
          environment-url: ${{ secrets.BUILD_ENV_URL }}
          app-id: ${{ secrets.CLIENT_ID }}
          client-secret: ${{ secrets.CLIENT_SECRET }}
          tenant-id: ${{ secrets.TENANT_ID }}
          path: out/ContosoCore_managed.zip
```

### 4.4 Key PAC CLI Commands

| Command | Purpose |
|---|---|
| `pac solution export --name X --path X.zip` | Export solution from environment |
| `pac solution pack --folder src --zipfile X.zip --packagetype Managed` | Pack from source to zip |
| `pac solution unpack --zipfile X.zip --folder src` | Unpack zip to source |
| `pac solution import --path X.zip --async` | Import solution to environment |
| `pac solution check --path X.zip` | Run Solution Checker |
| `pac solution clone --name X` | Clone solution into local project |
| `pac solution list` | List solutions in connected environment |

---

## 5. Solution Checker

### When to Run

- **Every PR** — automated in CI pipeline
- **Before import** to any non-dev environment
- **On demand** — during code reviews

### Severity Handling

| Severity | Action |
|---|---|
| **Critical** | Must fix before merge — blocks deployment |
| **High** | Must fix before merge — blocks deployment |
| **Medium** | Fix if possible; document justification if accepted |
| **Low** | Fix when convenient; acceptable to defer |
| **Informational** | Review and decide; no fix required |

### Common Issues Flagged

- Use of deprecated client APIs (`Xrm.Page`)
- Missing `await` on async calls
- Hardcoded URLs or GUIDs
- Plugins not using ITracingService
- Web resources with synchronous network calls
- Missing error handling

---

## 6. Version Control Strategy

### Solution Versioning

Follow **Semantic Versioning**: `major.minor.build.revision`

| Segment | When to Increment | Example |
|---|---|---|
| **Major** | Breaking changes, data model restructure | `2.0.0.0` |
| **Minor** | New features (backward compatible) | `1.3.0.0` |
| **Build** | Bug fixes | `1.2.1.0` |
| **Revision** | Hotfixes | `1.2.0.1` |

### Version Update Process

```bash
# Update solution version before export
pac solution online-version --solution-name ContosoCore --solution-version 1.3.0.0
```

### Assembly Versioning (Plugins)

Keep plugin assembly versions aligned with the solution version:

```xml
<!-- In .csproj or AssemblyInfo.cs -->
<AssemblyVersion>1.3.0.0</AssemblyVersion>
<FileVersion>1.3.0.0</FileVersion>
```

> **Important**: Changing the assembly `AssemblyVersion` requires re-registering the plugin assembly. Only change `FileVersion` for non-breaking updates.

---

## 7. Deployment Checklist

### Pre-Deployment

```markdown
- [ ] Solution Checker passed (no Critical/High issues)
- [ ] All unit tests passing
- [ ] All integration tests passing (if applicable)
- [ ] Code review completed and approved
- [ ] UAT sign-off obtained (for production deployments)
- [ ] Backup target environment
- [ ] Document rollback plan
- [ ] Notify stakeholders of deployment window
- [ ] Verify solution version is incremented
- [ ] Verify solution dependencies are already present in target
```

### Deployment

```markdown
- [ ] Import managed solution(s) in dependency order:
      1. Core (tables, columns, relationships)
      2. Plugins
      3. WebResources
      4. Flows
      5. UI (forms, views, dashboards)
      6. Security
- [ ] Activate Cloud Flows (if not auto-activated)
- [ ] Deactivate deprecated flows
- [ ] Apply data migrations or seed data (if any)
- [ ] Update environment variables for target environment
- [ ] Verify and fix connection references
- [ ] Update security role assignments (if new roles added)
```

### Post-Deployment

```markdown
- [ ] Verify all solution components are present (spot check)
- [ ] Run smoke tests — core business scenarios
- [ ] Verify plugin step registrations are active
- [ ] Verify integrations and connections are functional
- [ ] Check system jobs for errors
- [ ] Monitor plugin trace logs for 30 minutes
- [ ] Communicate deployment completion to stakeholders
- [ ] Update release notes / changelog
```

---

## 8. Hotfix Process

### Workflow

```
1. Create hotfix branch from production-aligned branch
   git checkout -b hotfix/PROJ-999-critical-fix main

2. Make minimal, targeted fix only
   - No refactoring
   - No feature additions
   - Only the specific bug fix

3. Fast-track through environments
   Dev → Test → UAT → Production
   (expedited approvals, reduced testing scope)

4. Backport to development branch
   git checkout develop
   git merge hotfix/PROJ-999-critical-fix

5. Tag the release
   git tag v1.2.0.1
```

### Hotfix Checklist

```markdown
- [ ] Hotfix branch created from main/production
- [ ] Fix is minimal and targeted
- [ ] Unit tests added/updated for the fix
- [ ] Solution Checker passed
- [ ] Emergency approval obtained
- [ ] Deployed to Test — quick validation
- [ ] Deployed to UAT — business sign-off
- [ ] Deployed to Production
- [ ] Backported to develop branch
- [ ] Post-mortem scheduled (if applicable)
```

---

## 9. Power Platform Pipelines (Native Deployment)

### Overview

Power Platform Pipelines provide a **built-in, no-code deployment mechanism** directly within the Power Platform admin center.

### Setup

1. **Install** the Power Platform Pipelines package in a dedicated "host" environment
2. **Link environments** in the pipeline configuration
3. **Define stages**: Dev → Validation → Test → Production
4. **Assign permissions**: Pipeline administrators and makers

### Pipeline Stages

```
Development ──► Validation ──► Test ──► Production
    (Unmanaged)    (Managed)    (Managed)   (Managed)
```

### Advantages

| Benefit | Detail |
|---|---|
| No external tools needed | Works within Power Platform — no Azure DevOps or GitHub required |
| Maker-friendly | Citizen developers can deploy without CI/CD expertise |
| Built-in approvals | Stage gates with approval workflows |
| Managed by default | Automatically exports as managed for target environments |
| Auditing | Full deployment history in the platform |

### Limitations

| Limitation | Workaround |
|---|---|
| Less customisable | Use Azure DevOps / GitHub Actions for complex pipelines |
| No plugin build step | Build plugins externally and include DLL in solution |
| Limited pre/post scripts | Use Power Automate flows for pre/post deployment tasks |
| No parallel deployments | Deploy to multiple test environments manually |
| Custom connectors not supported | Deploy custom connectors separately |

### When to Use What

| Scenario | Recommendation |
|---|---|
| Small team, citizen developers | Power Platform Pipelines |
| Pro-dev team, complex CI/CD | Azure DevOps or GitHub Actions |
| Mixed team | Pipelines for low-code; DevOps for pro-code |
| Regulated industry | Azure DevOps / GitHub Actions (full audit, custom gates) |

---

## Summary — ALM Maturity Model

| Level | Practice |
|---|---|
| **Level 1 — Ad Hoc** | Manual export/import, no source control |
| **Level 2 — Basic** | Source control, manual builds, managed solutions in non-dev |
| **Level 3 — Standard** | CI/CD pipelines, Solution Checker, automated tests |
| **Level 4 — Advanced** | Segmented solutions, environment strategy, deployment checklists |
| **Level 5 — Optimised** | Full automation, blue-green deployments, feature flags, telemetry |

> **Goal**: Every project should target at least **Level 3** from the start.
