# 3. Custom Instructions

[← Anterior: Instalación](02-instalacion.md) | [Siguiente: Skills y Custom Agents →](04-skills-agents.md)

---

## 📋 ¿Qué son?

Un fichero Markdown en tu repositorio que le dice al agente **cómo comportarse en tu proyecto**: stack tecnológico, convenciones de naming, restricciones y idioma de respuesta.

Se **carga automáticamente al inicio de cada sesión**. No tienes que recordárselas ni referenciarlas.

| Alcance | Fichero |
|---------|---------|
| **Proyecto** (solo este repositorio) | `.github/copilot-instructions.md` |
| **Global** (todos tus proyectos) | `~/.copilot/instructions.md` |

## 🛠️ Cómo crearlo

**Opción rápida — `/init`:** el agente analiza el proyecto y genera el fichero automáticamente.

```bash
copilot
> /init
```

**Opción manual:** crea `.github/copilot-instructions.md` y escribe directamente el contexto de tu proyecto.

## ✏️ Qué incluir

```markdown
## Stack tecnológico
- React 18 + TypeScript + Vite (frontend)
- Node.js + Express (backend)
- PostgreSQL + Prisma ORM

## Convenciones de naming
- Componentes: PascalCase (UserProfile.tsx)
- Servicios: camelCase (authService.ts)
- Constantes: UPPER_SNAKE_CASE

## Restricciones
- No instales dependencias sin consultarlo primero
- No mezcles lógica de negocio en componentes de UI

## Idioma
- Código y comentarios: inglés
- Respuestas: español
```

> 💡 **Consejo:** sé específico y conciso. Un fichero de 2–4 KB es suficiente. Más largo no es mejor — el texto extra consume contexto que el agente necesita para tu código.

---

[← Anterior: Instalación](02-instalacion.md) | [Siguiente: Skills y Custom Agents →](04-skills-agents.md)
