# Guía del Desarrollador — GitHub Copilot CLI

Guía práctica para sacar el máximo partido a **GitHub Copilot CLI** como agente autónomo en el terminal.

> **Versión de referencia:** GitHub Copilot CLI GA (25 de febrero de 2026)

## Qué vas a conseguir

Al terminar esta guía serás capaz de:

- Usar GitHub Copilot CLI como agente que planifica, edita ficheros y ejecuta comandos de forma autónoma
- Elegir el modelo adecuado (Sonnet / Haiku / Opus / GPT-4.1...) según la tarea para optimizar coste y velocidad
- Configurar custom instructions, skills y custom agents para tu stack
- Instalar plugins del marketplace de Capgemini y de la comunidad
- Conectar el agente a sistemas externos mediante servidores MCP

## Índice

| # | Sección | Descripción |
|---|---------|-------------|
| 1 | [🤖 ¿Qué es GitHub Copilot CLI?](01-que-es.md) | Modos de ejecución, agentes integrados, selección de modelo |
| 2 | [🛠️ Instalación y primeros pasos](02-instalacion.md) | Prerrequisitos, instalar el CLI, autenticación y comandos esenciales |
| 3 | [⚙️ Custom Instructions](03-custom-instructions.md) | Fichero de instrucciones del proyecto para personalizar el comportamiento del agente |
| 4 | [🧩 Skills y Custom Agents](04-skills-agents.md) | Skills especializadas, Custom Agents con restricciones y handoffs entre agentes |
| 5 | [🏪 Marketplace y Plugins](05-marketplace-plugins.md) | Qué son los plugins, repositorios clave y cómo instalarlos con ejemplos |
| 6 | [🔗 MCP: conexión a servicios externos](06-mcp.md) | Qué es MCP, configuración y ejemplo completo con Azure DevOps |

## ¿Por dónde empezar?

| Si eres... | Ruta recomendada |
|------------|-----------------|
| Nuevo en Copilot CLI | [01](01-que-es.md) → [02](02-instalacion.md) → [03](03-custom-instructions.md) |
| Desarrollador con Copilot, quiero sacar más partido | [03](03-custom-instructions.md) → [04](04-skills-agents.md) → [05](05-marketplace-plugins.md) |
| Solo me interesa conectar un sistema externo (Azure DevOps, Dataverse...) | [05](05-marketplace-plugins.md) → [06](06-mcp.md) |

---

[← Volver al marketplace](../README.md) | [Empezar: ¿Qué es GitHub Copilot CLI? →](01-que-es.md)
