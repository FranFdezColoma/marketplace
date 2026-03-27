# 2. Instalación y primeros pasos

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Custom Instructions →](03-custom-instructions.md)

---

## Prerrequisitos

- **Licencia GitHub Copilot** (Pro, Business o Enterprise)
- **GitHub CLI** — solicitar autorización en Service Central
- **PowerShell 7.0+** — solicitar autorización en Service Central
- **Node.js v18+** (recomendado v22+, disponible en el Marketplace de Capgemini)
- **npm v9+**

```powershell
node --version   # Debe ser v18.x.x o superior
npm --version    # Debe ser v9.x.x o superior
```

## Instalación

```bash
# Windows (WinGet) — recomendado
winget install GitHub.Copilot

# npm (todos los sistemas)
npm install -g @github/copilot

# macOS / Linux (Homebrew)
brew install copilot-cli

# macOS / Linux (script oficial)
curl -fsSL https://gh.io/copilot-install | bash
```

> **GitHub Codespaces:** Copilot CLI viene preinstalado. No necesitas instalarlo.

```bash
copilot --version   # Verificar la instalación
```

## Autenticación

```powershell
cd C:\Proyectos\MiProyecto
copilot
```

La primera vez te pedirá confirmar que confías en el directorio:

```
? Do you trust the files in this folder?
  ❯ Trust (for this session)
    Trust (always)
    Don't trust
```

Si es la primera vez o el token ha expirado:

```
> /login
# 1. El CLI muestra un código de un solo uso (ej: ABCD-1234)
# 2. Se abre el navegador en github.com/login/device
# 3. Introduce el código → Authorize
# 4. Vuelve al terminal — ya estás autenticado
```

> El login persiste entre sesiones. Solo necesitas hacerlo una vez.

## Comandos esenciales

### Sesión y cuenta

| Acción | Comando |
|--------|---------|
| Ayuda | `/help` |
| Iniciar sesión | `/login` |
| Cerrar sesión | `/logout` |
| Salir del CLI | `/exit` |
| Cambiar modelo de IA | `/model` |

### Proyecto y cambios

| Acción | Comando |
|--------|---------|
| Generar instrucciones del proyecto | `/init` |
| Ver cambios de la sesión | `/diff` |
| Revisar staged/unstaged | `/review` |
| Deshacer cambios | `Esc+Esc` |

### Modos de ejecución

| Acción | Comando |
|--------|---------|
| Alternar Plan / Autopilot | `Shift+Tab` |
| Delegar en segundo plano | `& <prompt>` |
| Retomar sesión delegada | `/resume` |

### Skills y plugins

| Acción | Comando |
|--------|---------|
| Listar skills activos | `/skills` |
| Añadir marketplace | `/plugin marketplace add <owner>/<repo>` |
| Instalar plugin | `/plugin install <plugin>@<marketplace>` |
| Listar plugins instalados | `/plugin list` |

### IDE

| Acción | Comando |
|--------|---------|
| Conectar con VS Code / Visual Studio | `/ide` |

## Flujo de trabajo habitual

```powershell
cd C:\Proyectos\MiProyecto
copilot

> Añade validación de email al formulario de registro y genera tests unitarios
# Si Plan Mode está activo (Shift+Tab): revisa el plan → aprueba → ejecuta

> /diff       # Revisa los cambios antes de hacer commit
# Esc+Esc     # Si algo no está bien, deshaz los cambios
```

---

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Custom Instructions →](03-custom-instructions.md)
