---
name: alm-pipeline
description: Configura un pipeline CI/CD completo para Power Platform con GitHub Actions o Azure DevOps. Genera los workflows/pipelines para exportar soluciones, ejecutar Solution Checker, ejecutar tests, importar en entornos y gestionar el ciclo de vida ALM completo. Úsalo cuando el usuario necesite "pipeline ci/cd", "alm setup", "github actions power platform", "azure devops pipeline", "automatizar despliegue solución", "configurar ci/cd dataverse".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires PAC CLI >= 2.3.1 and git. For GitHub Actions pipelines, also requires gh CLI.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[plataforma: github-actions o azure-devops; entornos disponibles: dev/test/prod; tipo de solución]"
---

# ALM Pipeline Setup — Power Platform CI/CD

**Triggers**: alm-pipeline, pipeline ci/cd, alm setup, github actions power platform, azure devops pipeline
**Aliases**: /alm, /alm-pipeline, /pipeline, /cicd

## Referencias

- **ALM Guidelines**: [alm-guidelines.md](../../references/alm-guidelines.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
pac --version         # PAC CLI instalado
gh --version          # GitHub CLI (si usas GitHub Actions)
az --version          # Azure CLI (si usas Azure DevOps)
git --version
```

Si falta alguna herramienta, indica al usuario dónde instalarla.

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Plataforma CI/CD?"** — GitHub Actions o Azure DevOps
2. **"¿Cuántos entornos?"** — Ej: Development → Test → Production
3. **"¿Nombre de la solución Dataverse?"** — Nombre lógico (ej: `MyCompanySolution`)
4. **"¿Hay plugins/PCF en la solución?"** — Para incluir pasos de build .NET / Node.js
5. **"¿Rama principal?"** — `main`, `master`, `develop`
6. **"¿Cómo se autentican los entornos?"** — Service Principal o PAC CLI auth

### Paso 3: Configurar Autenticación

```powershell
# Crear Service Principal en Azure AD para autenticación no interactiva
# Necesario para los pipelines CI/CD

# 1. Registrar aplicación en Azure AD
az ad app create --display-name "PowerPlatform-CICD-SP"

# 2. Crear credenciales
az ad app credential reset --id <APP_ID>

# 3. Crear Service Principal
az ad sp create --id <APP_ID>

# 4. Dar permisos en Power Platform (desde el portal de admin o con PAC CLI)
pac admin assign-user --environment <ENV_URL> --user <SP_APP_ID> --role "System Administrator"
```

Guarda los siguientes valores como **secrets** en GitHub / Azure DevOps:
- `POWER_PLATFORM_SP_APP_ID` — Application (client) ID
- `POWER_PLATFORM_SP_CLIENT_SECRET` — Client secret
- `POWER_PLATFORM_TENANT_ID` — Tenant ID

### Paso 4: Generar Pipeline

#### Opción A — GitHub Actions

Genera los siguientes workflows:

```yaml
# .github/workflows/export-solution.yml
# Exporta la solución desde el entorno de Development cuando hay cambios

name: Export Solution from DEV

on:
  workflow_dispatch:
    inputs:
      solution_name:
        description: 'Nombre lógico de la solución'
        required: true
        default: 'MyCompanySolution'

env:
  SOLUTION_NAME: ${{ github.event.inputs.solution_name }}
  BUILD_ENV_URL: ${{ secrets.BUILD_ENV_URL }}

jobs:
  export-from-dev:
    runs-on: windows-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Install PAC CLI
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Authenticate to DEV environment
        uses: microsoft/powerplatform-actions/who-am-i@v1
        with:
          environment-url: ${{ secrets.DEV_ENV_URL }}
          app-id: ${{ secrets.POWER_PLATFORM_SP_APP_ID }}
          client-secret: ${{ secrets.POWER_PLATFORM_SP_CLIENT_SECRET }}
          tenant-id: ${{ secrets.POWER_PLATFORM_TENANT_ID }}

      - name: Export Unmanaged Solution
        uses: microsoft/powerplatform-actions/export-solution@v1
        with:
          environment-url: ${{ secrets.DEV_ENV_URL }}
          app-id: ${{ secrets.POWER_PLATFORM_SP_APP_ID }}
          client-secret: ${{ secrets.POWER_PLATFORM_SP_CLIENT_SECRET }}
          tenant-id: ${{ secrets.POWER_PLATFORM_TENANT_ID }}
          solution-name: ${{ env.SOLUTION_NAME }}
          solution-output-file: ./solutions/${{ env.SOLUTION_NAME }}.zip
          managed: false

      - name: Unpack Solution
        uses: microsoft/powerplatform-actions/unpack-solution@v1
        with:
          solution-file: ./solutions/${{ env.SOLUTION_NAME }}.zip
          solution-folder: ./solutions/${{ env.SOLUTION_NAME }}
          solution-type: Unmanaged

      - name: Commit changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add ./solutions/
          git diff --staged --quiet || git commit -m "chore: export solution ${{ env.SOLUTION_NAME }} [skip ci]"
          git push
```

```yaml
# .github/workflows/build-deploy.yml
# Build y despliegue a Test y Production

name: Build and Deploy Solution

on:
  push:
    branches: [main]
    paths:
      - 'solutions/**'
  workflow_dispatch:
    inputs:
      target_env:
        description: 'Entorno destino'
        required: true
        type: choice
        options: [test, production]
        default: test

env:
  SOLUTION_NAME: MyCompanySolution

jobs:
  build:
    runs-on: windows-latest
    outputs:
      solution-version: ${{ steps.get-version.outputs.version }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Install PAC CLI
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Get solution version
        id: get-version
        run: |
          $version = (Select-Xml -Path "./solutions/${{ env.SOLUTION_NAME }}/Other/Solution.xml" -XPath "//Version").Node.InnerText
          echo "version=$version" >> $env:GITHUB_OUTPUT

      - name: Pack Managed Solution
        uses: microsoft/powerplatform-actions/pack-solution@v1
        with:
          solution-folder: ./solutions/${{ env.SOLUTION_NAME }}
          solution-file: ./out/${{ env.SOLUTION_NAME }}_managed.zip
          solution-type: Managed

      - name: Run Solution Checker
        uses: microsoft/powerplatform-actions/check-solution@v1
        with:
          environment-url: ${{ secrets.BUILD_ENV_URL }}
          app-id: ${{ secrets.POWER_PLATFORM_SP_APP_ID }}
          client-secret: ${{ secrets.POWER_PLATFORM_SP_CLIENT_SECRET }}
          tenant-id: ${{ secrets.POWER_PLATFORM_TENANT_ID }}
          path: ./out/${{ env.SOLUTION_NAME }}_managed.zip
          checker-logs-artifact-name: solution-checker-logs

      - name: Upload solution artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.SOLUTION_NAME }}-${{ steps.get-version.outputs.version }}-managed
          path: ./out/${{ env.SOLUTION_NAME }}_managed.zip
          retention-days: 30

  deploy-test:
    needs: build
    runs-on: windows-latest
    environment: test
    if: github.ref == 'refs/heads/main' || github.event.inputs.target_env == 'test'
    steps:
      - name: Download solution artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ env.SOLUTION_NAME }}-${{ needs.build.outputs.solution-version }}-managed
          path: ./out/

      - name: Install PAC CLI
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Import to TEST
        uses: microsoft/powerplatform-actions/import-solution@v1
        with:
          environment-url: ${{ secrets.TEST_ENV_URL }}
          app-id: ${{ secrets.POWER_PLATFORM_SP_APP_ID }}
          client-secret: ${{ secrets.POWER_PLATFORM_SP_CLIENT_SECRET }}
          tenant-id: ${{ secrets.POWER_PLATFORM_TENANT_ID }}
          solution-file: ./out/${{ env.SOLUTION_NAME }}_managed.zip
          force-overwrite: true
          publish-changes: true

  deploy-production:
    needs: [build, deploy-test]
    runs-on: windows-latest
    environment: production
    if: github.event.inputs.target_env == 'production'
    steps:
      - name: Download solution artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ env.SOLUTION_NAME }}-${{ needs.build.outputs.solution-version }}-managed
          path: ./out/

      - name: Install PAC CLI
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Import to PRODUCTION
        uses: microsoft/powerplatform-actions/import-solution@v1
        with:
          environment-url: ${{ secrets.PROD_ENV_URL }}
          app-id: ${{ secrets.POWER_PLATFORM_SP_APP_ID }}
          client-secret: ${{ secrets.POWER_PLATFORM_SP_CLIENT_SECRET }}
          tenant-id: ${{ secrets.POWER_PLATFORM_TENANT_ID }}
          solution-file: ./out/${{ env.SOLUTION_NAME }}_managed.zip
          force-overwrite: false
          publish-changes: true
```

#### Opción B — Azure DevOps

```yaml
# azure-pipelines.yml — Pipeline completo para Power Platform

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - solutions/*

variables:
  SolutionName: 'MyCompanySolution'
  BuildConfiguration: 'Release'

stages:

# ─── STAGE: BUILD ──────────────────────────────────────────────────────────────
- stage: Build
  displayName: 'Build & Solution Checker'
  jobs:
  - job: PackAndCheck
    displayName: 'Pack Managed Solution + Solution Checker'
    pool:
      vmImage: 'windows-latest'
    steps:
    - task: PowerPlatformToolInstaller@2
      displayName: 'Install PAC CLI'
      inputs:
        DefaultVersion: true

    - task: PowerPlatformPackSolution@2
      displayName: 'Pack Managed Solution'
      inputs:
        SolutionSourceFolder: '$(Build.SourcesDirectory)/solutions/$(SolutionName)'
        SolutionOutputFile: '$(Build.ArtifactStagingDirectory)/$(SolutionName)_managed.zip'
        SolutionType: 'Managed'

    - task: PowerPlatformChecker@2
      displayName: 'Run Solution Checker'
      inputs:
        authenticationType: 'PowerPlatformSPN'
        PowerPlatformSPN: 'BuildEnvironmentServiceConnection'
        FilesToAnalyze: '$(Build.ArtifactStagingDirectory)/$(SolutionName)_managed.zip'
        RuleSet: '0ad12346-e108-40b8-a956-9a8f95ea18c9'  # AppSource Certification

    - task: PublishBuildArtifacts@1
      displayName: 'Publish Solution Artifact'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: '$(SolutionName)-managed'

# ─── STAGE: DEPLOY TEST ───────────────────────────────────────────────────────
- stage: DeployTest
  displayName: 'Deploy to TEST'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: ImportTest
    displayName: 'Import Solution to TEST'
    pool:
      vmImage: 'windows-latest'
    environment: 'test'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: PowerPlatformToolInstaller@2
            displayName: 'Install PAC CLI'
            inputs:
              DefaultVersion: true

          - task: PowerPlatformImportSolution@2
            displayName: 'Import to TEST'
            inputs:
              authenticationType: 'PowerPlatformSPN'
              PowerPlatformSPN: 'TestEnvironmentServiceConnection'
              SolutionInputFile: '$(Pipeline.Workspace)/$(SolutionName)-managed/$(SolutionName)_managed.zip'
              ForceOverwrite: true
              PublishWorkflows: true

# ─── STAGE: DEPLOY PRODUCTION ─────────────────────────────────────────────────
- stage: DeployProduction
  displayName: 'Deploy to PRODUCTION'
  dependsOn: DeployTest
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: ImportProd
    displayName: 'Import Solution to PRODUCTION'
    pool:
      vmImage: 'windows-latest'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: PowerPlatformToolInstaller@2
            displayName: 'Install PAC CLI'
            inputs:
              DefaultVersion: true

          - task: PowerPlatformImportSolution@2
            displayName: 'Import to PRODUCTION'
            inputs:
              authenticationType: 'PowerPlatformSPN'
              PowerPlatformSPN: 'ProdEnvironmentServiceConnection'
              SolutionInputFile: '$(Pipeline.Workspace)/$(SolutionName)-managed/$(SolutionName)_managed.zip'
              ForceOverwrite: false
              PublishWorkflows: true
```

### Paso 5: Configurar Secrets y Service Connections

#### GitHub Secrets (Settings → Secrets → Actions)

```
DEV_ENV_URL             → https://yourorg-dev.crm.dynamics.com
TEST_ENV_URL            → https://yourorg-test.crm.dynamics.com
PROD_ENV_URL            → https://yourorg-prod.crm.dynamics.com
BUILD_ENV_URL           → https://yourorg-build.crm.dynamics.com
POWER_PLATFORM_SP_APP_ID       → <Application ID del Service Principal>
POWER_PLATFORM_SP_CLIENT_SECRET → <Client Secret>
POWER_PLATFORM_TENANT_ID       → <Tenant ID>
```

#### GitHub Environments (Settings → Environments)

Crea entornos `test` y `production` con:
- **Required reviewers** para `production` (aprobación manual antes del despliegue)
- **Deployment branches**: solo `main`

#### Azure DevOps Service Connections

En Project Settings → Service Connections → New → Power Platform:
- `BuildEnvironmentServiceConnection`
- `TestEnvironmentServiceConnection`  
- `ProdEnvironmentServiceConnection`

### Paso 6: Estructura de Carpetas Recomendada

```
repo-root/
├── .github/
│   └── workflows/
│       ├── export-solution.yml     ← Exportar desde DEV
│       └── build-deploy.yml        ← Build + Deploy a TEST/PROD
├── solutions/
│   └── MyCompanySolution/          ← Solución desempaquetada
│       ├── Entities/
│       ├── Workflows/
│       ├── WebResources/
│       └── Other/
│           └── Solution.xml
├── src/                            ← Código pro code
│   ├── MyPlugin/
│   └── MyPlugin.Tests/
├── pcf/                            ← PCF Controls
└── README.md
```

### Paso 7: Resumen Final

```powershell
# Verificar que el pipeline está configurado correctamente
gh workflow list
gh secret list
```

- ✅ Workflows generados y explicados
- ✅ Service Principal y secrets configurados
- ✅ Entornos con protección de despliegue
- 📌 Próximos pasos: `/code-review` antes del primer despliegue a producción
