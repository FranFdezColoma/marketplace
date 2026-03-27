# 1. ¿Qué es GitHub Copilot CLI?

[← Índice](README.md) | [Siguiente: Instalación →](02-instalacion.md)

---

GitHub Copilot CLI es un **agente de IA nativo del terminal** disponible para todas las suscripciones de pago de GitHub Copilot. A diferencia de Copilot en VS Code (que sugiere mientras escribes), el CLI **actúa de forma autónoma**: planifica, edita múltiples ficheros, ejecuta comandos y recuerda el contexto del repositorio entre sesiones.

```bash
copilot
> Refactoriza el módulo de autenticación para separar la lógica de negocio de la UI,
> ejecuta los tests y muéstrame un diff antes de aplicar los cambios.
```

| | Copilot en VS Code | Copilot CLI |
|---|---|---|
| Tipo | Asistente reactivo | Agente autónomo |
| Actúa cuando | Tú escribes | Tú describes una tarea |
| Edita ficheros | No (solo sugiere) | Sí, múltiples a la vez |
| Ejecuta comandos | No | Sí (shell, tests, builds) |
| Recuerda el contexto | Solo en la sesión de chat | Entre sesiones (memoria del repo) |

## Modos de ejecución

### Plan Mode

El agente analiza la petición, genera un plan de implementación y espera tu aprobación antes de ejecutar ningún cambio.

**Cuándo usarlo:** cambios que afectan a múltiples ficheros, decisiones de arquitectura, cualquier tarea donde quieras supervisar cada paso.

**Activación:** `Shift+Tab`

```bash
# Plan Mode activo (Shift+Tab)
> Migra la capa de acceso a datos de REST a GraphQL

# El agente responde con:
# Plan de implementación:
# 1. Analizar los endpoints REST actuales en /src/api/
# 2. Instalar las dependencias de Apollo Client
# 3. Crear el esquema GraphQL equivalente
# 4. Actualizar los componentes que consumen la API
# 5. Ejecutar los tests de integración
# ¿Apruebas este plan? (s/n)
```

### Autopilot Mode

Para tareas bien definidas, el agente trabaja de forma completamente autónoma sin pausas.

**Cuándo usarlo:** generar tests, renombrar variables, aplicar conventions, corregir errores de compilación.

**Activación:** `Shift+Tab` (alterna entre Plan y Autopilot)

## Agentes integrados

Copilot CLI delega automáticamente en sub-agentes especializados según la tarea:

| Agente | Función |
|--------|---------|
| **Explore** | Análisis del código base sin contaminar el contexto principal |
| **Task** | Ejecuta builds, tests y comandos de shell |
| **Code Review** | Analiza cambios antes del commit |
| **Plan** | Planificación de implementaciones |
| **Fleet** | Ejecutar múltiples tareas en paralelo (`/fleet`) |

### Delegación en segundo plano

```bash
# Prefija con & para delegar en la nube y seguir trabajando
& Genera una suite completa de tests unitarios para el módulo src/payments/
# ... haces otras cosas mientras el agente trabaja en segundo plano ...
> /resume   # Retomas cuando esté listo
```

## Selección de modelo

Elegir bien el modelo es la palanca más directa para optimizar **calidad / coste / velocidad**.

> **Regla de oro:** usa el modelo más barato que resuelva tu tarea. Sube un nivel solo si el resultado no es satisfactorio tras dos intentos.

```bash
> /model   # Muestra lista interactiva de modelos disponibles
```

| Modelo | Coste | Velocidad | Para qué |
|--------|-------|-----------|----------|
| **GPT-4.1 / GPT-5 mini** | 0x — incluido | ⚡⚡⚡ | Preguntas sobre código, documentar, renombrar |
| **Claude Haiku 4.5** | 0.33x | ⚡⚡⚡ | Tests unitarios sencillos, refactorizaciones menores |
| **Claude Sonnet 4.6** ⭐ | 1x | ⚡⚡ | Módulos completos, refactorizaciones multi-fichero, revisión de código |
| **Claude Opus 4.6** | 3x | ⚡ | Arquitecturas complejas, bugs difíciles de diagnosticar |

> Los modelos gratuitos (0x) no consumen cuota de _premium requests_. Úsalos sin restricción para tareas simples.

```bash
# Tarea simple → modelo gratuito
> /model gpt-4.1
> ¿Qué hace el método calculateDiscount en src/pricing.ts?

# Refactorización multi-fichero → Sonnet (recomendado por defecto)
> /model claude-sonnet-4.6
> Refactoriza el módulo de autenticación para usar el patrón Repository

# Arquitectura compleja → Opus (solo si Sonnet no es suficiente)
> /model claude-opus-4.6
> Diseña la arquitectura de un sistema de procesamiento de eventos en tiempo real
```

## Extensibilidad

- **Custom Instructions** — contexto permanente del proyecto (ver [sección 3](03-custom-instructions.md))
- **Skills** — conocimiento especializado por dominio (ver [sección 4](04-skills-agents.md))
- **Plugins** — bundles instalables del marketplace (ver [sección 5](05-marketplace-plugins.md))
- **MCP** — conexión a servicios externos en tiempo real (ver [sección 6](06-mcp.md))

## Referencias

- [Documentación oficial Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [Copilot CLI for Beginners — Quick Start](https://github.com/github/copilot-cli-for-beginners/tree/main/00-quick-start)

---

[← Índice](README.md) | [Siguiente: Instalación →](02-instalacion.md)
