---
name: doc-generator
description: Genera documentación técnica completa para soluciones Power Platform. Crea READMEs, ADRs, documentación de APIs (OpenAPI), changelogs, guías de usuario, runbooks, diagramas de arquitectura Mermaid y especificaciones técnicas. Aplica el framework Diátaxis y Microsoft Writing Style Guide. Úsalo cuando el usuario necesite "documenta esto", "genera el README", "escribe la documentación", "crea un ADR", "documenta la API", "genera el changelog", "escribe el runbook".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[qué documentar: tipo de doc, audiencia, componente/API/sistema a documentar]"
---

# Documentation Generator

**Triggers**: doc-generator, documenta, genera el readme, escribe la documentación, crea un adr, documenta la api
**Aliases**: /docs, /doc-generator, /document

## Referencias

- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)
- **Patrones**: [dataverse-patterns.md](../../references/dataverse-patterns.md)

---

## Instrucciones

### Paso 1: Recopilar Contexto

Lee los ficheros existentes antes de escribir:

```powershell
# Leer la estructura del proyecto
Get-ChildItem -Recurse -Include "*.cs","*.ts","*.md","*.json" | Select-Object FullName
```

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Qué necesitas documentar?"** — Componente específico, API, proyecto completo
2. **"¿Quién es la audiencia?"** — Desarrolladores, usuarios finales, arquitectos, negocio
3. **"¿Qué tipo de documento?"** — README, ADR, API Reference, How-to Guide, Runbook, etc.

### Paso 2: Determinar el Tipo de Documento (Diátaxis)

| Tipo | Propósito | Cuándo usarlo |
|------|-----------|---------------|
| **Tutorial** | Aprender haciendo — ejercicio guiado | Onboarding de nuevos desarrolladores |
| **How-to Guide** | Resolver tarea concreta — pasos secuenciales | "Cómo desplegar la solución", "Cómo configurar X" |
| **Reference** | Información técnica precisa | API reference, schema, configuración |
| **Explanation** | Entender el por qué — contexto | Decisiones de arquitectura, ADRs, conceptos |

### Paso 3: Generar el Documento

#### README de Proyecto

```markdown
# [Nombre del Proyecto]

> [Tagline: Una frase que describe qué hace el proyecto]

[![Solution Checker](badge-url)](link)
[![Version](badge-url)](link)

## Descripción

[2-3 párrafos: qué es, qué problema resuelve, para quién]

## Stack Tecnológico

| Componente | Tecnología |
|-----------|-----------|
| Data layer | Dataverse |
| Backend | C# (Plugins, Custom APIs) |
| Frontend | TypeScript + React + Fluent UI V9 |
| Automation | Power Automate |
| CI/CD | GitHub Actions + PAC CLI |

## Prerequisitos

- [ ] Power Platform environment (Development)
- [ ] PAC CLI instalado (`dotnet tool install --global Microsoft.PowerApps.CLI.Tool`)
- [ ] Node.js >= 16
- [ ] .NET SDK >= 6.0
- [ ] Autenticación PAC CLI configurada

## Instalación

```powershell
# 1. Clonar repositorio
git clone https://github.com/[org]/[repo].git
cd [repo]

# 2. Autenticar con Power Platform
pac auth create --environment https://[org].crm.dynamics.com

# 3. Importar solución en entorno de desarrollo
pac solution import --path ./solutions/[SolutionName].zip

# 4. Instalar dependencias (PCF / web resources)
npm install
```

## Estructura del Proyecto

```
[project-root]/
├── solutions/            # Power Platform solutions
│   └── [SolutionName]/   # Solution source files
├── src/
│   ├── plugins/          # C# Dataverse plugins
│   ├── pcf/              # PCF controls
│   └── webresources/     # TypeScript web resources
├── tests/                # Unit tests
├── docs/                 # Technical documentation
│   ├── adr/              # Architecture Decision Records
│   └── api/              # API reference
└── .github/workflows/    # CI/CD pipelines
```

## Desarrollo

```powershell
# Compilar plugins
dotnet build src/plugins/ -c Debug

# Ejecutar tests
dotnet test tests/ -v normal

# Build PCF
cd src/pcf/[ComponentName]
npm run build

# Publicar cambios al entorno de desarrollo
pac pcf push --publisher-prefix src
pac plugin push --pluginFile ./bin/Debug/[Plugin].dll
```

## Despliegue

Ver [docs/deployment-guide.md](docs/deployment-guide.md) para instrucciones completas.

El despliegue a Test y Production se realiza automáticamente mediante el pipeline CI/CD al hacer merge a `main`.

## Contribución

1. Crea una rama: `git checkout -b feat/nombre-funcionalidad`
2. Commit con Conventional Commits: `git commit -m "feat: descripción"`
3. Push y crea un Pull Request
4. El pipeline CI/CD ejecuta Solution Checker automáticamente

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para detalles.

## Versionado

Seguimos [Semantic Versioning](https://semver.org/). Ver [CHANGELOG.md](CHANGELOG.md).

## Licencia

MIT — [Nombre Organización]
```

#### Architecture Decision Record (ADR)

```markdown
# ADR-[N]: [Título de la Decisión]

**Fecha**: [YYYY-MM-DD]
**Estado**: Propuesto | Aceptado | Deprecated | Superseded por ADR-[N]
**Autores**: [nombres]
**Revisores**: [nombres]

## Contexto

[Describe el problema o situación que requiere esta decisión. Incluye:
- Contexto del proyecto
- Restricciones relevantes
- Requerimientos que guían la decisión]

## Decisión

[Descripción clara y concisa de la decisión tomada]

## Alternativas Consideradas

### Opción A: [Nombre] ✅ (Seleccionada)
**Descripción**: ...
**Pros**:
- ...
**Contras**:
- ...

### Opción B: [Nombre] ❌
**Descripción**: ...
**Razón del descarte**: ...

### Opción C: [Nombre] ❌
**Descripción**: ...
**Razón del descarte**: ...

## Consecuencias

### Positivas
- ...

### Negativas / Riesgos
- ...

### Acciones Derivadas
- [ ] [Acción necesaria como resultado de esta decisión]

## Referencias

- [Link a documentación oficial de Microsoft Learn]
- [Link a issue o PR relacionado]
```

#### API Reference (Custom API Dataverse)

```markdown
# API Reference: [Nombre]

**Unique Name**: `src_[ApiName]`
**Versión**: 1.0.0
**Tipo**: Action | Function
**Binding**: Global | Entity (`[entity_logical_name]`) | Entity Collection

## Descripción

[Qué hace esta API, en qué casos de uso se usa]

## Autenticación

Requiere autenticación OAuth 2.0 con token de Dataverse.

## Endpoint

```
POST [org]/api/data/v9.2/[optional: entity(id)/Microsoft.Dynamics.CRM.]src_[ApiName]
```

## Parámetros de Entrada

| Nombre | Tipo OData | Requerido | Descripción | Ejemplo |
|--------|-----------|-----------|-------------|---------|
| `InputParam1` | `Edm.String` | Sí | Descripción | `"value"` |
| `InputParam2` | `Edm.Decimal` | No | Descripción | `100.50` |

## Parámetros de Salida

| Nombre | Tipo OData | Descripción |
|--------|-----------|-------------|
| `Result` | `Edm.String` | Descripción |
| `IsSuccess` | `Edm.Boolean` | Si la operación fue exitosa |
| `ErrorMessage` | `Edm.String` | Mensaje de error (si aplica) |

## Ejemplos

### Request

```http
POST https://org.crm.dynamics.com/api/data/v9.2/src_ApiName
Content-Type: application/json
Authorization: Bearer {token}

{
    "InputParam1": "value",
    "InputParam2": 100.50
}
```

### Response (Success)

```json
{
    "@odata.context": "...",
    "Result": "processed",
    "IsSuccess": true,
    "ErrorMessage": ""
}
```

### Response (Error)

```json
{
    "Result": "",
    "IsSuccess": false,
    "ErrorMessage": "Descripción del error"
}
```

## Códigos de Error

| Código HTTP | Descripción | Solución |
|-------------|-------------|---------|
| 400 | Parámetros inválidos | Verificar tipos y valores requeridos |
| 401 | No autenticado | Renovar token OAuth |
| 403 | Sin permisos | Verificar rol de seguridad |
| 404 | Registro no encontrado | Verificar el ID del registro |

## Invocación desde TypeScript

```typescript
const result = await Xrm.WebApi.online.execute({
    getMetadata: () => ({
        operationType: 0, // Action
        operationName: "src_ApiName",
        boundParameter: "entity",
        parameterTypes: {
            entity: { typeName: "mscrm.[entity]", structuralProperty: 5 },
            InputParam1: { typeName: "Edm.String", structuralProperty: 1 }
        }
    }),
    entity: { [entity]id: recordId, "@odata.type": "Microsoft.Dynamics.CRM.[entity]" },
    InputParam1: "value"
});
```
```

### Paso 4: Guardar el Documento

```powershell
# El documento se guarda en la ubicación adecuada del proyecto
# README.md → raíz del repositorio
# ADRs → docs/adr/ADR-[N]-[título].md
# API Reference → docs/api/[api-name].md
# Runbooks → docs/runbooks/[runbook-name].md
```

### Paso 5: Resumen Final

- Documento generado y guardado en la ubicación correcta
- Tipo de documento: [tipo según Diátaxis]
- Audiencia objetivo: [audiencia]
- Próximos pasos: revisión por el equipo, incluir en PR junto con los cambios de código
