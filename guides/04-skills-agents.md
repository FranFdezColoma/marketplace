# 4. Skills y Custom Agents

[← Anterior: Custom Instructions](03-custom-instructions.md) | [Siguiente: Marketplace y Plugins →](05-marketplace-plugins.md)

---

## 🔀 Los tres mecanismos de personalización

Copilot CLI tiene tres formas de personalizar el comportamiento del agente. Cada una tiene un propósito distinto:

| | Custom Instructions | Skills | Custom Agents |
|---|---|---|---|
| **Qué es** | Contexto permanente del proyecto | Conocimiento especializado de un dominio | Perfil con rol, herramientas y modelo definidos |
| **Cuándo está activo** | Siempre, en toda la sesión | Solo cuando el contexto lo requiere | Solo cuando lo seleccionas explícitamente |
| **Se activa** | Automáticamente al arrancar | Automáticamente por palabras clave | Manualmente desde el selector de agentes |
| **Ejemplo** | "Usa TypeScript, responde en español" | "Al revisar código, aplica OWASP y muestra severidad" | `solution-architect`: solo lee, no modifica |

> 💡 Si usas un **plugin del marketplace** (sección 5), ya tienes skills y custom agents listos. No necesitas crearlos tú.

## 🛠️ Skills

Una skill es un conjunto de instrucciones especializadas que el agente carga **automáticamente** cuando detecta que la tarea lo requiere, basándose en palabras clave.

**Cómo se activan:** describe la tarea con naturalidad. El agente detecta el contexto y carga las skills relevantes.

```bash
> /skills   # Ver las skills activas en la sesión
```

### Ejemplo — Code Reviewer 🔴🟡🔵

```bash
# La skill se activa cuando mencionas "revisar", "review", "calidad de código"...
> Revisa los cambios de este PR antes de hacer merge

# El agente devuelve:
  🔴 CRÍTICO   src/auth/tokenService.ts:47
     El token JWT se almacena en localStorage. Vulnerable a XSS.
     → Usa httpOnly cookies en su lugar.

  🟡 ADVERTENCIA   src/api/userController.ts:112
     No se valida el input del campo "email" antes de persistirlo.
     → Añade validación con zod o class-validator.

  🔵 SUGERENCIA   src/components/UserForm.tsx:23
     El componente mezcla lógica de negocio con la UI.
     → Extrae la validación a un custom hook useUserForm.
```

### Ejemplo — .NET Project Creator

```bash
# La skill se activa cuando mencionas "nuevo proyecto .NET", "crear solución", "scaffolding"...
> Crea un nuevo proyecto de API REST en .NET 8 con autenticación JWT y Entity Framework

# El agente genera:
  ✓ Solución creada: MyApi.sln
  ✓ Proyectos:
    MyApi/          → Web API (controllers, middleware, Program.cs)
    MyApi.Core/     → Entidades, interfaces, DTOs
    MyApi.Infra/    → EF Core, repositorios, configuración de BD
    MyApi.Tests/    → xUnit + Moq

  ✓ Configurado: JWT Bearer auth, Swagger, connection string en appsettings.json
  ✓ Ejecuta: dotnet run --project MyApi
```

## 🤖 Custom Agents

Un Custom Agent es un perfil especializado que puedes seleccionar para una tarea concreta. Cada agente tiene un **rol definido**, unas **herramientas específicas** y un **modelo de IA** configurado.

**Cómo se seleccionan:** desde el selector de agentes al iniciar una conversación.

### Agente — Solution Architect 🏛️

```bash
# Selecciona "Solution Architect" en el selector
> Necesitamos un sistema de notificaciones en tiempo real para nuestra app

# El agente analiza el contexto y propone:
  Propuesta de arquitectura: WebSockets + Redis Pub/Sub

  Componentes:
  ├── NotificationHub (ASP.NET SignalR) — gestiona conexiones WS
  ├── Redis          — canal de mensajes entre servicios
  └── NotificationWorker — consume eventos y los publica

  ADR-007: Se descarta SSE porque necesitamos comunicación bidireccional.
  ADR-008: Redis frente a RabbitMQ por latencia y simplicidad operacional.

  → Pulsa [▶ Implementar] para pasar el plan al agente Developer
```

### Agente — Developer 👨‍💻

```bash
# Selecciona "Developer" en el selector
> Implementa el endpoint POST /api/orders con validación y tests unitarios

# El agente implementa:
  ✓ OrdersController.cs       — endpoint con validación FluentValidation
  ✓ CreateOrderCommandHandler — lógica de negocio (patrón CQRS)
  ✓ OrderRepository.cs        — acceso a datos con EF Core
  ✓ OrdersControllerTests.cs  — 8 tests unitarios con xUnit + Moq
  ✓ Todos los tests pasan ✅
```

### Agente — Documenter 📝

```bash
# Selecciona "Documenter" en el selector
> Genera la documentación técnica del módulo de pagos

# El agente genera:
  ✓ README.md actualizado con la descripción del módulo
  ✓ docs/payments-architecture.md — diagrama y decisiones de diseño
  ✓ docs/api-reference.md — endpoints documentados con ejemplos de request/response
  ✓ CHANGELOG.md — entrada para los cambios recientes
```

## 📌 ¿Cuándo usar cada uno?

| Situación | Usa... |
|-----------|--------|
| Quiero que el agente siempre sepa mi stack y mis convenciones | **Custom Instructions** |
| Voy a revisar código y quiero feedback con severidad por colores | **Skill** (Code Reviewer) |
| Necesito crear un nuevo proyecto desde cero con scaffolding | **Skill** (.NET Project Creator) |
| Quiero diseñar una arquitectura sin que el agente toque código | **Custom Agent** (Solution Architect) |
| Quiero implementar una feature con tests incluidos | **Custom Agent** (Developer) |
| Necesito generar documentación técnica de un módulo | **Custom Agent** (Documenter) |
| Instalo el plugin de mi stack | Obtengo **skills + agents** listos para usar |

## 📚 Referencias

- [VS Code Docs: Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [VS Code Docs: Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Colección de la comunidad (awesome-copilot)](https://github.com/github/awesome-copilot)

---

[← Anterior: Custom Instructions](03-custom-instructions.md) | [Siguiente: Marketplace y Plugins →](05-marketplace-plugins.md)
