# 3. Marketplace y Plugins

[← Anterior: Instalación](02-instalacion.md) | [Siguiente: Custom Instructions, Skills y Agents →](04-custom-instructions-skills-agents.md)

## ¿Qué es el Marketplace?

El marketplace de Agent Skills es un **ecosistema de repositorios públicos en GitHub** donde Microsoft, Anthropic, GitHub y la comunidad publican colecciones de skills, plugins e instrucciones listas para usar.

El estándar [agentskills.io](https://agentskills.io) garantiza compatibilidad: un skill publicado en cualquier marketplace funciona en **GitHub Copilot CLI, Claude Code y VS Code agent mode** indistintamente.

---

## ¿Qué es un Plugin?

Un plugin es un **bundle instalable** del marketplace que agrupa skills, custom agents e instrucciones especializadas para un stack tecnológico. Con un solo comando tienes todo listo para trabajar.

## ⚡ Cómo instalar un plugin

```bash
copilot
> /plugin marketplace add <owner>/<repo>           # Registrar el marketplace
> /plugin install <nombre-plugin>@<marketplace>    # Instalar el plugin
> /plugin list                                     # Verificar instalación
```

## 🗂️ Repositorios de ejemplo

| Repositorio | Qué incluye |
|-------------|-------------|
| [FranFdezColoma/marketplace](https://github.com/FranFdezColoma/marketplace) | Power Platform, Dataverse, Dynamics 365 |
| [microsoft/power-platform-skills](https://github.com/microsoft/power-platform-skills) | Power Pages, Model-Driven Apps (oficial Microsoft) |
| [microsoft/skills](https://github.com/microsoft/skills) | Azure SDK: .NET, Python, TypeScript, Java |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | (Viene por defecto en Github Copilot CLI) Todos los stacks: React, Django, Go, Docker, CI/CD... |

## 🎯 Qué instalar según tu stack

### Power Platform / Dataverse (Ejemplo)

```bash
> /plugin marketplace add FranFdezColoma/marketplace
> /plugin install dynamics365-powerplatform@marketplace

> /plugin marketplace add microsoft/power-platform-skills
> /plugin install power-pages@power-platform-skills

> /plugin marketplace add github/awesome-copilot
> /plugin install dataverse@awesome-copilot 

```

Una vez instalado, los skills están disponibles en tu sesión:

```bash
copilot
> /dataverse-schema "Diseña las tablas para un módulo de gestión de incidencias"
> /plugin-builder "Crea un plugin pre-operation en Incident que valide la prioridad"
> /unit-test-builder "Genera tests unitarios para IncidentValidationPlugin.cs"
> /code-review "Revisa IncidentPlugin.cs aplicando mejores prácticas de Dataverse"
```

## 🔧 Troubleshooting

**El plugin no aparece tras la instalación:**

```bash
> /plugin list   # Verifica que está instalado
copilot          # Reinicia la sesión si es necesario
```

## 📚 Referencias

- [agentskills.io](https://agentskills.io) — Especificación del estándar
- [github/awesome-copilot](https://github.com/github/awesome-copilot)
- [microsoft/power-platform-skills](https://github.com/microsoft/power-platform-skills)

---

[← Anterior: Instalación](02-instalacion.md) | [Siguiente: Custom Instructions, Skills y Agents →](04-custom-instructions-skills-agents.md)