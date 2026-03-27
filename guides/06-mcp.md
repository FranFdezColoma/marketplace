# 6. MCP: conexión a servicios externos

[← Anterior: Marketplace y Plugins](05-marketplace-plugins.md) | [← Volver al índice](README.md)

---

## 🔌 ¿Qué es MCP?

**Model Context Protocol (MCP)** permite a Copilot CLI conectarse a **servicios externos** en tiempo real: bases de datos, APIs, herramientas de CI/CD, gestores de proyectos, etc.

Con MCP conectado, en vez de limitarte a lo que hay en tu repositorio, el agente puede **consultar y operar directamente contra el servicio**.

| | Sin MCP | Con MCP |
|---|---|---|
| **Dataverse** | Escribe FetchXML basándose en lo que describes | Lee el esquema real de tu entorno |
| **Azure DevOps** | No puede acceder a tus pipelines | Consulta runs, crea work items, gestiona sprints |
| **Jira / GitHub Issues** | No puede acceder a tus tickets | Crea, actualiza y consulta issues en tiempo real |

## ⚙️ Configuración rápida

Los servidores MCP se registran en un fichero JSON:

| Alcance | Fichero |
|---------|---------|
| Todos tus proyectos | `~/.copilot/mcp-config.json` |
| Solo este repositorio | `.mcp/copilot/mcp.json` |

**Servidores tipo `stdio`** (paquetes npm o ejecutables locales):

```json
{
  "mcpServers": {
    "NombreServidor": {
      "type": "stdio",
      "command": "nombre-ejecutable",
      "args": ["--organization", "https://..."],
      "env": { "TOKEN": "tu-token" }
    }
  }
}
```

**Servidores tipo `http`** (como el MCP de Dataverse):

```json
{
  "mcpServers": {
    "DataverseMcp": {
      "type": "http",
      "url": "https://tuorganizacion.crm.dynamics.com/api/mcp"
    }
  }
}
```

Reinicia el CLI y verifica:

```bash
copilot
> /mcp list
# NombreServidor  ✓  connected
```

## 💡 Ejemplo: Azure DevOps MCP

### Instalación y configuración

```bash
npm install -g @azure-devops/mcp-server
```

Edita `~/.copilot/mcp-config.json`:

```json
{
  "mcpServers": {
    "AzureDevOps": {
      "type": "stdio",
      "command": "azure-devops-mcp",
      "args": ["--organization", "https://dev.azure.com/TU_ORGANIZACION"],
      "env": { "AZURE_DEVOPS_PAT": "TU_PAT_TOKEN" }
    }
  }
}
```

> Necesitas un [Personal Access Token](https://learn.microsoft.com/es-es/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate) con permisos de lectura/escritura sobre Work Items, Build y Code.

### Lo que puedes hacer una vez conectado

```
> ¿Qué proyectos tenemos en la organización?
  • CustomerPortal  • InternalTools  • PowerPlatformALM

> Muéstrame los pipelines fallidos en CustomerPortal en las últimas 24h.
  ✗ CI-Build #2341 — Fallido hace 3h
    Causa: Error de compilación en CustomerCard/index.ts:47

> Crea un bug en CustomerPortal: "PCF src_CustomerCard no muestra teléfono en mobile",
  prioridad 2, asignado a mí, en el sprint actual.
  ✓ Bug #4821 creado — Sprint 14

> Dame un resumen del sprint actual de PowerPlatformALM.
  Sprint 8 | 23 items | 61% completado | 1 bloqueado
```

## 🖥️ Integración con IDEs

### VS Code

```
Ctrl+Shift+P → "MCP: Add Server" → introduce la URL → activa modo agente (Ctrl+Alt+I)
```

### Visual Studio 2026

Instala la extensión **[CopilotCliIde](https://github.com/sailro/CopilotCliIde)** (disponible en Extensiones de Visual Studio) y ejecuta `/ide` en el CLI para conectar:

```bash
copilot
> /ide
# ✓ Connected to Visual Studio
# El agente ve la solución, el código seleccionado y la lista de errores en tiempo real
```

## 📚 Referencias

- [Model Context Protocol — especificación](https://modelcontextprotocol.io)
- [Microsoft Learn — MCP Dataverse](https://learn.microsoft.com/es-es/power-apps/maker/data-platform/data-platform-mcp-vscode)
- [CopilotCliIde — repositorio](https://github.com/sailro/CopilotCliIde)

---

[← Anterior: Marketplace y Plugins](05-marketplace-plugins.md) | [← Volver al índice](README.md)
