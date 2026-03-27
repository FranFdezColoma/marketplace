# 🟦 dynamics365-powerplatform

> Plugin profesional de **Fran** para desarrollo en Microsoft Power Platform, Dataverse y Dynamics 365.

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./.claude-plugin/plugin.json)
[![Agents](https://img.shields.io/badge/agents-3-purple)](#-agentes)
[![Skills](https://img.shields.io/badge/skills-11-green)](#-skills)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](../../README.md#licencia)

---

## 📚 Recursos y Buenas Prácticas

> Consulta estos recursos antes de empezar o cuando necesites referencia rápida.

| Recurso | Descripción |
|---------|-------------|
| [📐 Naming Conventions (EN)](best-practices/naming-conventions-en.md) | Estándar de nomenclatura para tablas, columnas, PCF, C#, flows y soluciones |
| [🧪 Unit Testing Guide (ES)](best-practices/unit-testing-es.md) | Guía completa de testing para plugins .NET y Web Resources JavaScript |
| [📖 Convenciones de Naming](references/naming-conventions.md) | Referencia rápida de naming por artefacto |
| [🏗️ Patrones Dataverse](references/dataverse-patterns.md) | Patrones y mejores prácticas para C#, TypeScript y OData |
| [🔄 ALM Guidelines](references/alm-guidelines.md) | ALM, entornos, pipelines y gestión del ciclo de vida |

---

## 📋 Descripción

Este plugin proporciona a equipos de desarrollo **3 agentes especializados** y **11 skills** que cubren el ciclo de vida completo de desarrollo sobre Power Platform: desde el diseño de arquitectura hasta la documentación técnica, pasando por el desarrollo pro code y la configuración de pipelines ALM.

Compatible con **GitHub Copilot CLI** y **Claude Code** (estándar AgentSkills).

---

## 🚀 Instalación

```bash
/plugin install dynamics365-powerplatform@fran-marketplace
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

**Actívalo con**: _"Necesito diseñar la arquitectura de..."_, _"¿Cómo modelaría los datos para...?"_, _"Analiza este requerimiento..."_

### 💻 Developer
Desarrollador senior especializado en el ecosistema Microsoft. Escribe código C# para plugins y Custom APIs, TypeScript para PCF controls y Web Resources, y configura Power Automate flows de calidad productiva.

**Actívalo con**: _"Escribe un plugin para..."_, _"Crea un PCF component que..."_, _"Necesito un flow que..."_

### 📝 Documenter
Experto en documentación técnica de software. Genera documentación siguiendo el framework Diátaxis: tutoriales, how-to guides, reference y explanation. Produce READMEs, ADRs, OpenAPI specs, changelogs y guías de usuario.

**Actívalo con**: _"Documenta este componente..."_, _"Genera el README de..."_, _"Crea un ADR para..."_

---

## 🛠️ Skills

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

---

## 📦 Stack soportado

| Categoría | Tecnologías |
|-----------|-------------|
| **Pro Code** | C# (Plugins, Custom APIs), TypeScript (PCF, Web Resources), FetchXML |
| **Low Code** | Power Automate, Canvas Apps, Model-Driven Apps, Power Pages |
| **Data** | Dataverse, Dataverse Web API (OData v4), FetchXML, QueryExpression |
| **DevOps** | PAC CLI, GitHub Actions, Azure DevOps, Power Platform Build Tools |
| **Testing** | MSTest + Moq, Vitest + xrm-mock, Jest |
| **IDEs** | Visual Studio 2022, VS Code |

---

## 📐 Convenciones rápidas

Ver guía completa → [📐 Naming Conventions (EN)](best-practices/naming-conventions-en.md)

| Artefacto | Patrón | Ejemplo |
|-----------|--------|---------|
| Tabla custom Dataverse | `{prefix}_{entity_name}` | `src_work_order` |
| Componente PCF | `{Publisher}_{ControlName}` | `src_CustomerCard` |
| Clase C# Plugin | `{Entity}{Action}Plugin` | `OpportunityValidatePlugin` |
| Power Automate Flow | `[Scope]_[Entity]_[Action]` | `Sales_Opportunity_NotifyOnWin` |
| Fichero TypeScript | camelCase | `customerService.ts` |
| Constante | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |

---

[← Volver a plugins](../README.md) | [← Volver al marketplace](../../README.md)