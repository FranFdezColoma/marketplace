# dynamics365-powerplatform

Plugin profesional de Capgemini para desarrollo en **Microsoft Power Platform**, **Dataverse** y **Dynamics 365**.

## Descripción

Este plugin proporciona a equipos de desarrollo tres agentes especializados y once skills que cubren el ciclo de vida completo de desarrollo sobre Power Platform: desde el diseño de arquitectura hasta la documentación técnica, pasando por el desarrollo pro code y la configuración de pipelines ALM.

Compatible con **GitHub Copilot CLI** y **Claude Code** (estándar AgentSkills).

## Instalación

```bash
/plugin install dynamics365-powerplatform@capgemini-marketplace
```

O localmente:

```bash
claude --plugin-dir /path/to/dynamics365-powerplatform
copilot --plugin-dir /path/to/dynamics365-powerplatform
```

## Agentes

### 🏛️ Solution Architect
Arquitecto experto en Power Platform, Dynamics 365 y Dataverse. Diseña soluciones escalables siguiendo el principio OOB → Low Code → Pro Code. Genera ADRs, modelos de datos, arquitecturas de seguridad y planes de integración.

**Actívalo**: "Necesito diseñar la arquitectura de...", "¿Cómo modelaría los datos para...?", "Analiza este requerimiento..."

### 💻 Developer
Desarrollador senior especializado en el ecosistema Microsoft. Escribe código C# para plugins y Custom APIs, TypeScript para PCF controls y Web Resources, y configura Power Automate flows de calidad productiva.

**Actívalo**: "Escribe un plugin para...", "Crea un PCF component que...", "Necesito un flow que..."

### 📝 Documenter
Experto en documentación técnica de software. Genera documentación siguiendo el framework Diátaxis: tutoriales, how-to guides, reference y explanation. Produce READMEs, ADRs, OpenAPI specs, changelogs y guías de usuario.

**Actívalo**: "Documenta este componente...", "Genera el README de...", "Crea un ADR para..."

## Skills

| Skill | Invocación | Descripción |
|-------|-----------|-------------|
| Diseño de datos Dataverse | `/dataverse-schema` | Modelo de datos con tablas, relaciones, nomenclatura |
| C# Plugin Builder | `/plugin-builder` | Plugins Dataverse con IPlugin, tracing, tests |
| PCF Control Builder | `/pcf-builder` | PCF con TypeScript, React, Fluent UI |
| Power Automate Builder | `/flow-builder` | Flows con naming, env vars, error handling |
| Custom API Builder | `/custom-api` | Custom APIs con definición y handler C# |
| ALM Pipeline Setup | `/alm-pipeline` | CI/CD GitHub Actions / Azure DevOps |
| Security Design | `/security-design` | Roles, OWS, Column Security, DLP |
| Documentation Generator | `/doc-generator` | Docs técnica completa (Diátaxis) |
| Code Review | `/code-review` | Revisión con severidad 🔴🟡🔵 |
| Unit Test Builder | `/unit-test-builder` | Tests unitarios C# (MSTest+Moq) y JS/TS (Vitest+xrm-mock) |
| Pull Request | `/pull-request` | Crear PR con git + gh CLI y descripción estructurada |

## Stack soportado

- **Pro Code**: C# (Plugins, Custom APIs), TypeScript (PCF, Web Resources), FetchXML
- **Low Code**: Power Automate, Canvas Apps, Model-Driven Apps, Power Pages
- **Data**: Dataverse, Dataverse Web API (OData v4), FetchXML, QueryExpression
- **DevOps**: PAC CLI, GitHub Actions, Azure DevOps, Power Platform Build Tools
- **Testing**: MSTest + Moq, Vitest + xrm-mock, Jest
- **IDEs**: Visual Studio 2022, VS Code

## Convenciones

Ver [references/naming-conventions.md](references/naming-conventions.md)

- **Componentes PCF**: `src_CustomerCard` (PascalCase con prefijo publisher)
- **Tablas custom Dataverse**: `src_customer_profile` (snake_case con prefijo)
- **Ficheros TypeScript**: `customerService.ts` (camelCase)
- **Constantes**: `MAX_RETRY_COUNT` (UPPER_SNAKE_CASE)
- **Respuestas**: en español; código en inglés
