# 🧩 Plugins

Catálogo de plugins disponibles en el marketplace. Cada plugin es una unidad instalable que agrupa **agents**, **skills** y **references** especializadas para un stack tecnológico concreto.

---

## 📦 Plugins disponibles

| Plugin | Stack | Estado | Agentes | Skills |
|--------|-------|--------|---------|--------|
| [🟦 dynamics365-powerplatform](dynamics365-powerplatform/README.md) | Power Platform · Dataverse · Dynamics 365 | ✅ Estable | 3 | 11 |
| [☁️ salesforce](salesforce/README.md) | Salesforce · Apex · LWC · SFDX | 🚧 En construcción | — | — |

---

## ⚡ Instalación rápida

```bash
copilot
# 1. Registrar el marketplace
> /plugin marketplace add FranFdezColoma/marketplace

# 2. Instalar el plugin de tu stack
> /plugin install dynamics365-powerplatform@marketplace
> /plugin install salesforce@marketplace

# 3. Verificar instalación
> /plugin list
```

---

## 🗂️ Estructura de un plugin

Todo plugin sigue esta estructura estándar:

```
plugins/<nombre>/
├── .claude-plugin/
│   └── plugin.json      ← Metadata: nombre, versión, agents, skills, keywords
├── agents/              ← Custom Agents con roles definidos (.md)
├── skills/              ← Skills activables por contexto (subcarpetas con SKILL.md)
├── references/          ← Documentación técnica de referencia
├── best-practices/      ← Guías de buenas prácticas
└── README.md            ← Descripción, instalación y tabla de skills
```

---

## ➕ Añadir un nuevo plugin

1. Crea la carpeta `plugins/<tu-stack>/`
2. Copia la estructura del [plugin de referencia](dynamics365-powerplatform/)
3. Rellena `plugin.json` con los metadatos del plugin
4. Añade tu plugin a la tabla de esta página
5. Abre un Pull Request

> 💡 Consulta [AGENTS.md](dynamics365-powerplatform/AGENTS.md) del plugin de referencia para entender las convenciones de authoring de agents y skills.

---

[← Volver al marketplace](../README.md)