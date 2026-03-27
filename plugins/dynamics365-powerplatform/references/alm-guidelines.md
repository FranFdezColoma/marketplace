# ALM Guidelines — Power Platform (Fran)

Guía de Application Lifecycle Management para soluciones Microsoft Power Platform y Dataverse.

---

## 1. Estrategia de Entornos

### Topología Recomendada

```
┌──────────────┐    Export     ┌─────────────┐    Deploy (Managed)    ┌─────────────┐
│  Development │  ──────────►  │    Test     │  ────────────────────► │     UAT     │
│  (Sandbox)   │  Unmanaged    │  (Sandbox)  │                        │  (Sandbox)  │
└──────────────┘               └─────────────┘                        └─────────────┘
       │                                                                      │
       │ Solo desarrollo                                                      │ Aprobación
       │ y exportación                                                        ▼
       │                                                               ┌─────────────┐
       │                                                               │  Production │
       └──────────────────────────────────────────────────────────────►│ (Production)│
                                                                       └─────────────┘
```

### Tipos de Entorno

| Entorno | Tipo Power Platform | Propósito | Acceso |
|---------|-------------------|-----------|--------|
| Development | Sandbox | Desarrollo activo, exploración | Devs + Admins |
| Test | Sandbox | Testing funcional, integración | Devs + QA |
| UAT | Sandbox | Aceptación por usuarios clave | Key Users + QA |
| Production | Production | Uso real del negocio | Usuarios finales |

### Reglas de Entornos

- **Nunca** desarrolles directamente en Test/UAT/Production
- **Nunca** importes Unmanaged Solutions en Test, UAT o Production
- **Solo** el pipeline CI/CD puede importar soluciones en Test, UAT y Production
- Los usuarios finales **nunca** tienen acceso a Development
- Las customizaciones manuales en Production son **bloqueadas** por las Managed Solutions

---

## 2. Estructura de Solutions

### Tipos de Solutions

| Tipo | Cuándo usar |
|------|------------|
| **Single solution** | Proyectos pequeños, un módulo |
| **Layered solutions** | Proyectos grandes; base + módulos funcionales |
| **Patch solutions** | Hotfixes urgentes (evitar siempre que sea posible) |

### Estructura Recomendada (Layered)

```
FranBase (v1.0.0)           ← Tablas, columnas base, tipos globales
└── FranSalesModule (v1.0.0) ← Componentes específicos de ventas
    └── FranSalesFlows (v1.0.0) ← Solo Power Automate flows del módulo
```

### Qué incluir en cada Solution

| Artefacto | ¿En Solution? | Notas |
|-----------|--------------|-------|
| Tablas y columnas | ✅ Sí | Siempre |
| Security Roles | ✅ Sí | Para despliegue consistente |
| Plugins registrados | ✅ Sí | Pasos de plugin incluidos |
| PCF Controls | ✅ Sí | Assemby + componente |
| Web Resources | ✅ Sí | .js, .css, .html |
| Power Automate Flows | ✅ Sí | **Solo flows de solución**, nunca standalone |
| Environment Variables | ✅ Sí | Definición (no valores — se configuran por entorno) |
| Connection References | ✅ Sí | Para flows que usan conectores |
| Canvas Apps | ✅ Sí | Si forman parte de la solución |
| Model-Driven Apps | ✅ Sí | Configuración de la app |
| Data de referencia | ❌ No | Gestionada por Configuration Migration Tool |

---

## 3. Source Control — Estructura del Repositorio

### Estructura Recomendada

```
[project-repo]/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Build, validate, Solution Checker
│       └── deploy.yml          # Deploy to environments
├── solutions/
│   └── [SolutionName]/         # Solution source files (pac solution unpack)
│       ├── Solution.xml        # Solution manifest
│       ├── Entities/           # Table/column definitions
│       ├── Workflows/          # Power Automate flows
│       ├── WebResources/       # Web resources
│       └── PluginAssemblies/   # Plugin registration
├── src/
│   ├── plugins/
│   │   ├── [PluginProject]/
│   │   │   ├── [Plugin].cs
│   │   │   └── [Plugin].csproj
│   │   └── [PluginProject].sln
│   ├── pcf/
│   │   └── [ComponentName]/
│   │       ├── index.ts
│   │       ├── ControlManifest.Input.xml
│   │       └── package.json
│   └── webresources/
│       └── [Module]/
│           └── [webresource].ts
├── tests/
│   ├── [PluginProject].Tests/
│   └── [PCFComponent]/__tests__/
├── docs/
│   ├── adr/                    # Architecture Decision Records
│   ├── api/                    # API Reference
│   └── guides/                 # How-to guides
├── scripts/                    # Utility scripts (export, import, etc.)
├── CHANGELOG.md
└── README.md
```

### Exportar Solution para Git

```powershell
# Exportar y unpack la solution de Development
pac auth create --environment [dev-env-url]

# Exportar la solución (Unmanaged)
pac solution export `
    --path ./solutions/temp/[SolutionName].zip `
    --name [SolutionName] `
    --managed false

# Unpack para versionado en Git
pac solution unpack `
    --zipfile ./solutions/temp/[SolutionName].zip `
    --folder ./solutions/[SolutionName] `
    --allowDelete true `
    --allowWrite true

# Limpiar zip temporal
Remove-Item ./solutions/temp/[SolutionName].zip
```

### Pack y Import desde Git

```powershell
# Pack desde fuente
pac solution pack `
    --zipfile ./out/[SolutionName].zip `
    --folder ./solutions/[SolutionName] `
    --ziptype Unmanaged

# Pack Managed para despliegue
pac solution pack `
    --zipfile ./out/[SolutionName]_managed.zip `
    --folder ./solutions/[SolutionName] `
    --ziptype Managed

# Import en entorno destino
pac auth create --environment [target-env-url]
pac solution import `
    --path ./out/[SolutionName]_managed.zip `
    --force-overwrite `
    --publish-changes
```

---

## 4. Solution Checker

El Solution Checker debe ejecutarse en **cada Pull Request** y **cada despliegue**.

```powershell
# Ejecutar Solution Checker con PAC CLI
pac solution check --path ./out/[SolutionName].zip --outputDirectory ./checker-results

# Ver resultados
Get-Content ./checker-results/*.sarif | ConvertFrom-Json
```

### Categorías de Issues

| Categoría | Qué detecta |
|-----------|-------------|
| `performance` | Consultas LINQ/FetchXML ineficientes, plugins síncronos pesados |
| `usage` | APIs deprecadas, patrones obsoletos |
| `security` | Vulnerabilidades de seguridad potenciales |
| `supportability` | Código difícil de mantener o soportar |

### Política de Quality Gate

```
Configuración recomendada para el pipeline:
- Critical errors: BLOQUEAN el despliegue
- High errors: BLOQUEAN el despliegue
- Medium errors: ADVERTENCIA (no bloquean)
- Low errors: Informativo (no bloquean)
```

---

## 5. Versioning — SemVer para Power Platform

```
Major.Minor.Patch.Build

Reglas:
- Major (X.0.0.0): Cambios incompatibles — nueva solución base, rediseño de tabla
- Minor (1.X.0.0): Nueva funcionalidad backward-compatible — nuevo campo, nuevo flow
- Patch (1.0.X.0): Bug fixes — corrección de plugin, ajuste de flow
- Build (1.0.0.X): Automático por el pipeline CI/CD — nunca editar manualmente

Proceso de cambio de versión:
1. Actualizar en Solution.xml antes de hacer merge a main
2. Actualizar CHANGELOG.md con los cambios
3. El pipeline genera el Build number automáticamente
```

### CHANGELOG Template

```markdown
# Changelog

## [Unreleased]
### Added
- Nueva columna `src_priority` en tabla `src_work_order`

## [1.2.0] - 2024-03-15
### Added
- Plugin `OrderEscalationPlugin` para escalado automático
- Flow `Service_Case_EscalateOnTimeout`
### Fixed
- Bug en `OrderValidationPlugin` al procesar importes negativos
### Changed
- Renombrada columna `src_total` → `src_total_amount` para mayor claridad

## [1.1.0] - 2024-02-01
### Added
- PCF Control `src_CustomerRating`
- Custom API `src_CalculateOrderTotal`
```

---

## 6. Checklist ALM Completo

### Antes de Desarrollar (Sprint Planning)
- [ ] Entorno de desarrollo disponible y autenticado
- [ ] Rama de Git creada: `feat/nombre-funcionalidad`
- [ ] Dependencias de solution verificadas
- [ ] Solution exportada desde Dev (estado actual en Git)

### Durante el Desarrollo
- [ ] Todos los artefactos añadidos a la solución en Dev
- [ ] Variables de entorno creadas (no hardcoding)
- [ ] Naming conventions seguidas
- [ ] Tests unitarios escritos y pasando
- [ ] Código revisado con `/code-review`

### Antes del Merge (Pull Request)
- [ ] Solution exportada y unpacked en el branch
- [ ] CHANGELOG.md actualizado
- [ ] Versión de solution incrementada (si es release)
- [ ] Solution Checker ejecutado sin Critical/High errors
- [ ] Tests unitarios: `dotnet test` / `npm test` — todos PASS
- [ ] Documentación actualizada (`/doc-generator`)
- [ ] PR description completa con descripción del cambio

### Pipeline CI/CD (Automático)
- [ ] Build de plugins y PCF
- [ ] Tests unitarios
- [ ] Pack solution (Unmanaged)
- [ ] Solution Checker
- [ ] Deploy a Test (Managed)
- [ ] [Manual] Aprobación para UAT
- [ ] Deploy a UAT (Managed)
- [ ] [Manual] Aprobación para Production
- [ ] Deploy a Production (Managed)

### Rollback
```powershell
# Importar versión anterior desde artefacto del pipeline anterior
pac solution import `
    --path ./[PreviousVersion]_managed.zip `
    --force-overwrite `
    --publish-changes
```
