# 🟦 dynamics365-powerplatform

> Plugin profesional para desarrollo en Microsoft Power Platform, Dataverse y Dynamics 365.

[![Version](https://img.shields.io/badge/version-1.1.0-blue)](./.claude-plugin/plugin.json)
[![Agentes](https://img.shields.io/badge/agentes-3-purple)](#-agentes)
[![Skills](https://img.shields.io/badge/skills-11-green)](#-skills)
[![Licencia](https://img.shields.io/badge/licencia-MIT-lightgrey)](../../README.md#license)

---

## 📚 Recursos y Referencias

> Consulta estos recursos antes de empezar o cuando necesites una referencia rápida.

| Recurso | Descripción |
|---------|-------------|
| [📐 Convenciones de Nombrado](references/naming-conventions.md) | Estándares de nomenclatura para tablas, columnas, PCF, C#, flows y soluciones |
| [🏗️ Patrones Dataverse](references/dataverse-design-patterns.md) | Patrones de arquitectura y buenas prácticas para C#, TypeScript y OData |
| [🔒 Modelo de Seguridad](references/security-model.md) | Arquitectura de seguridad: jerarquía de BU, roles, equipos y seguridad a nivel de campo |
| [🔄 Gestión de Soluciones](references/solution-management.md) | ALM, entornos, pipelines y ciclo de vida de soluciones |

---

## 📋 Descripción

Este plugin proporciona a los equipos de desarrollo **3 agentes especializados** y **11 skills** que cubren el ciclo de vida completo en Power Platform: desde el diseño de arquitectura hasta la documentación técnica, pasando por el desarrollo pro code y la configuración ALM.

Compatible con **GitHub Copilot CLI** y **Claude Code**.

---

## 🚀 Instalación

```bash
/plugin marketplace add FranFdezColoma/marketplace
/plugin install dynamics365-powerplatform@marketplace
```

O localmente:

```bash
claude --plugin-dir /path/to/dynamics365-powerplatform
copilot --plugin-dir /path/to/dynamics365-powerplatform
```

---

## 🤖 Agentes

### 🏛️ Solution Architect
Arquitecto experto en Power Platform, Dynamics 365 y Dataverse. Diseña soluciones escalables siguiendo el principio OOB → Low Code → Pro Code. Genera ADRs, modelos de datos, arquitecturas de seguridad y planes de integración.


### 💻 Developer
Desarrollador senior especializado en el ecosistema Microsoft. Escribe código C# para plugins y Custom APIs, TypeScript para controles PCF y Web Resources, y configura flows de Power Automate de calidad productiva. Sigue los principios SOLID, DRY, YAGNI, KISS.


### 📝 Documenter
Especialista en documentación técnica de software. Genera documentación siguiendo el framework Diátaxis: tutoriales, how-to guides, referencia y explicación. Produce READMEs, ADRs, specs OpenAPI, changelogs y guías de usuario.


---

## 🛠️ Skills

| Skill | Alias | Descripción |
|-------|-------|-------------|
| ADR Creator | `/adr` | Registros de decisiones de arquitectura siguiendo el estándar MADR |
| arc42 | `/arc42` | Documentación de arquitectura usando la plantilla arc42 (12 secciones) |
| Code Review | `/code-review`, `/review` | Revisión de código con severidad estructurada 🔴🟠🟡🔵 |
| Custom API Builder | `/custom-api` | Custom APIs con definición, handler C# y registro PAC CLI |
| Documentation Generator | `/doc-generator`, `/docs` | Documentación técnica completa (framework Diátaxis) |
| Flow Builder | `/flow-builder`, `/flow` | Flows de Power Automate de calidad productiva |
| Jira Issue Creator | `/jira-issue-creator` | Work items Jira/Azure DevOps con casos de prueba en Gherkin |
| PCF Control Builder | `/pcf-builder`, `/pcf` | Controles PCF con TypeScript, React y Fluent UI V9 |
| Plugin Builder | `/plugin-builder`, `/plugin` | Plugins C# para Dataverse con IPlugin, trazado y tests |
| Solution Design | `/solution-design` | Diseño de solución completo con diagramas Mermaid |
| Unit Test Builder | `/unit-test-builder`, `/test` | Tests unitarios: C# (MSTest + Moq) y JS/TS (Vitest + xrm-mock) |

---

## 📦 Stack Soportado

| Categoría | Tecnologías |
|-----------|-------------|
| **Pro Code** | C# (Plugins, Custom APIs), TypeScript (PCF, Web Resources), FetchXML |
| **Low Code** | Power Automate, Canvas Apps, Model-Driven Apps, Power Pages |
| **Datos** | Dataverse, Dataverse Web API (OData v4), FetchXML, QueryExpression |
| **DevOps** | PAC CLI, GitHub Actions, Azure DevOps, Power Platform Build Tools |
| **Testing** | MSTest + Moq, Vitest + xrm-mock, Jest |
| **IDEs** | Visual Studio 2022, VS Code |

---

## 📐 Convenciones Rápidas

Guía completa → [📐 Convenciones de Nombrado](references/naming-conventions.md)

| Artefacto | Patrón | Ejemplo |
|-----------|--------|---------|
| Tabla personalizada Dataverse | `{prefijo}_{nombre_entidad}` | `src_work_order` |
| Componente PCF | `{Publisher}_{ControlName}` | `src_CustomerCard` |
| Clase plugin C# | `{Entidad}{Accion}Plugin` | `OpportunityValidatePlugin` |
| Flow Power Automate | `[prefix]_[Entidad]_[Trigger]_[Propósito]` | `Sales_Opportunity_OnWin_NotifyTeam` |
| Fichero TypeScript | camelCase | `customerService.ts` |
| Constante | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |

---

## 🔗 Dependencias MCP (Recomendadas)

| MCP | Propósito |
|-----|-----------|
| **Microsoft Learn MCP** | Acceso a documentación oficial y verificación de SDKs |
| **Dataverse MCP** | Metadatos del entorno e inspección de tablas |
| **Atlassian MCP** | Creación e inspección de issues en Jira |

---

[← Volver a plugins](../README.md) | [← Volver al marketplace](../../README.md)
