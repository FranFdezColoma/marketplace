# 5. Marketplace y Plugins

[← Anterior: Skills y Custom Agents](04-skills-agents.md) | [Siguiente: MCP →](06-mcp.md)

---

## 📦 ¿Qué es un Plugin?

Un plugin es un **bundle instalable** del marketplace que agrupa skills, custom agents e instrucciones especializadas para un stack tecnológico. Con un solo comando tienes todo listo para trabajar.

## ⚡ Cómo instalar un plugin

```bash
copilot
> /plugin marketplace add <owner>/<repo>           # Registrar el marketplace
> /plugin install <nombre-plugin>@<marketplace>    # Instalar el plugin
> /plugin list                                     # Verificar instalación
```

## 🗂️ Repositorios disponibles

| Repositorio | Qué incluye |
|-------------|-------------|
| [FranFdezColoma/capgemini-marketplace](https://github.com/FranFdezColoma/capgemini-marketplace) | Power Platform, Dataverse, Dynamics 365 |
| [microsoft/power-platform-skills](https://github.com/microsoft/power-platform-skills) | Power Pages, Model-Driven Apps (oficial Microsoft) |
| [microsoft/skills](https://github.com/microsoft/skills) | Azure SDK: .NET, Python, TypeScript, Java |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | Todos los stacks: React, Django, Go, Docker, CI/CD... |

## 🎯 Qué instalar según tu stack

### Power Platform / Dataverse

```bash
> /plugin marketplace add FranFdezColoma/capgemini-marketplace
> /plugin install dynamics365-powerplatform@capgemini-marketplace

> /plugin marketplace add microsoft/power-platform-skills
> /plugin install power-pages@power-platform-skills

> /plugin marketplace add github/awesome-copilot
> /plugin install dataverse@awesome-copilot   # Incluye skill para conectar MCP
```

### .NET / Azure

```bash
> /plugin marketplace add microsoft/skills
> /plugin marketplace add github/awesome-copilot
```

### Frontend (React / TypeScript) o Full-stack (Node.js / Python)

```bash
> /plugin marketplace add github/awesome-copilot
```

## 💡 Ejemplo de uso tras instalar

Una vez instalado el plugin de GitHub Actions:

```
> El último workflow de CI está fallando. ¿Qué step ha fallado y por qué?

  ✗ Run tests (step 3/6)
  Error: ENOENT: no such file or directory, open 'coverage/lcov.info'
  Causa: los tests se abortaron antes de generar el reporte de cobertura.
  Sugerencia: añade --coverage --coverageReporters=lcov a jest.

> Los últimos tres PRs tienen el pipeline de lint fallando. Relanza todos.
  ✓ PR #142 — relanzado
  ✓ PR #139 — relanzado
  ✓ PR #137 — relanzado
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

[← Anterior: Skills y Custom Agents](04-skills-agents.md) | [Siguiente: MCP →](06-mcp.md)
