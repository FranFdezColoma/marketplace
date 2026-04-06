# 6. Ejemplo práctico de principio a fin

[← Anterior: MCP: conexión a servicios externos](05-mcp.md) | [← Volver al índice](README.md)

---

En este ejemplo vas a recorrer, paso a paso, el flujo completo que describe esta guía: instalar el plugin del marketplace, configurar las custom instructions, usar una skill y usar un custom agent. Todo desde cero en un proyecto real.

> ⏱️ Tiempo estimado: 15–20 minutos

---

## 🎯 Qué vas a hacer

1. Preparar un proyecto de ejemplo en tu máquina
2. Instalar el plugin de Dynamics 365 / Power Platform desde el marketplace
3. Configurar las custom instructions con `/init`
4. Usar una skill para revisar un fragmento de código (Code Reviewer)
5. Usar un custom agent para implementar una feature (Developer)

---

## 📁 Paso 1 — Crea una carpeta de proyecto

Abre **PowerShell** (desde el terminal de VS Code o de forma independiente) y crea una carpeta de trabajo:

```powershell
mkdir C:\Proyectos\CopilotDemo
cd C:\Proyectos\CopilotDemo
```

Lanza el CLI desde esa carpeta:

```powershell
copilot
```

Cuando te pregunte si confías en el directorio:

```
? Do you trust the files in this folder?
  ❯ Trust (always)
```

Selecciona **Trust (always)** para no tener que confirmarlo en cada sesión.

---

## 🔐 Paso 2 — Verifica tu autenticación

Si es la primera vez, ejecuta:

```
> /login
```

El CLI mostrará un código de un solo uso. Sigue las instrucciones en pantalla para autenticarte en github.com con tu cuenta corporativa.

Una vez autenticado, verifica que todo funciona:

```
> ¿Qué puedes hacer?
```

El agente debería responder describiendo sus capacidades. Si ves un error de autenticación, vuelve al [Paso 3 de la instalación](02-instalacion.md#-paso-3--activar-la-cuenta-en-el-emu-de-github).

---

## 📦 Paso 3 — Instala el plugin del marketplace

```
> /plugin marketplace add FranFdezColoma/marketplace
```

Cuando te pregunte qué plugin instalar, elige `dynamics365-powerplatform`:

```
> /plugin install dynamics365-powerplatform@dynamics365-powerplatform
```

Verifica que el plugin está instalado y sus skills activas:

```
> /skills
```

Deberías ver las skills del plugin (code-reviewer, solution-architect, developer, documenter...).

---

## 📝 Paso 4 — Configura las Custom Instructions con `/init`

Las custom instructions le dan al agente contexto permanente sobre tu proyecto.

```
> /init
```

El agente analizará la carpeta y generará un fichero `.github/copilot-instructions.md`. Cuando termine, ábrelo y personalízalo con la información de tu proyecto:

```powershell
# Desde PowerShell, fuera del CLI:
notepad .github\copilot-instructions.md
```

Ajusta el contenido para que refleje tu stack real. Por ejemplo:

```markdown
## Stack tecnológico
- Power Platform (Power Apps Canvas, Model-Driven)
- Dataverse (tablas personalizadas, flujos)
- .NET 8 (plugins de Dataverse)
- Azure Functions (integraciones)

## Convenciones de naming
- Soluciones: PascalCase sin espacios (ej: FranSalesCore)
- Tablas: prefijo `src_` en minúsculas (ej: src_opportunity)
- Variables de entorno: UPPER_SNAKE_CASE

## Idioma
- Código y comentarios: inglés
- Respuestas: español
```

Guarda el fichero. La próxima vez que arranques el CLI, leerá estas instrucciones automáticamente.

---

## 🔍 Paso 5 — Usa la skill de Code Review

Crea un fichero de ejemplo con un par de problemas intencionados:

```powershell
# Desde PowerShell, fuera del CLI:
@"
using System;

public class OrderService
{
    public void CreateOrder(string customerId, decimal amount)
    {
        // TODO: validar parámetros
        Console.WriteLine("Creando orden para: " + customerId);
        var query = "SELECT * FROM orders WHERE customer = '" + customerId + "'";
        // ...guardar en base de datos
    }
}
"@ | Set-Content OrderService.cs
```

Ahora vuelve al CLI y pide una revisión:

```
> Revisa el fichero OrderService.cs antes de hacer merge
```

La skill de Code Review se activará automáticamente. Deberías ver algo similar a:

```
🔴 CRÍTICO   OrderService.cs:9
   SQL concatenado directamente con datos del usuario. Vulnerable a SQL Injection.
   → Usa parámetros preparados o un ORM como EF Core.

🟡 ADVERTENCIA   OrderService.cs:5
   No se validan los parámetros de entrada (customerId podría ser null o vacío,
   amount podría ser negativo).
   → Añade validación al inicio del método.

🔵 SUGERENCIA   OrderService.cs:7
   Console.WriteLine en código de producción.
   → Sustituye por un logger (ILogger<OrderService>).
```

---

## 🤖 Paso 6 — Usa el Custom Agent Developer

Ahora pide al agente Developer que corrija los problemas del paso anterior:

```
> Selecciona el agente Developer y corrige los problemas de seguridad de OrderService.cs:
  - Reemplaza el SQL concatenado por parámetros preparados
  - Añade validación de parámetros al inicio del método
  - Sustituye Console.WriteLine por ILogger
```

> 💡 Puedes cambiar de agente desde el selector al inicio de la conversación o en medio de la sesión escribiendo `@developer`.

El agente debería generar una versión corregida del fichero con los tres problemas resueltos. Revisa los cambios antes de aceptarlos:

```
> Muéstrame los cambios antes de aplicarlos
```

Una vez conforme:

```
> Aplica los cambios
```

---

## ✅ Resultado final

Al terminar este ejemplo habrás:

- ✔️ Instalado y verificado el plugin del marketplace
- ✔️ Generado custom instructions personalizadas para tu proyecto
- ✔️ Usado la skill de Code Review para detectar problemas de seguridad
- ✔️ Usado el agente Developer para corregirlos de forma autónoma

---

## 🔗 Próximos pasos

| Quiero... | Ir a... |
|-----------|---------|
| Conectar el agente a Dataverse en tiempo real | [05 — MCP](05-mcp.md) |
| Crear mis propias skills o agents | [04 — Custom Instructions, Skills y Agents](04-custom-instructions-skills-agents.md) |
| Explorar más plugins del marketplace | [03 — Marketplace y Plugins](03-marketplace-plugins.md) |

---

[← Anterior: MCP: conexión a servicios externos](05-mcp.md) | [← Volver al índice](README.md)
