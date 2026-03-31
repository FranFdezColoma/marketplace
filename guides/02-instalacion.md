# 2. Instalación y primeros pasos

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Marketplace y Plugins →](03-marketplace-plugins.md)

---

## Prerrequisitos

- **Licencia GitHub Copilot** (Pro, Business o Enterprise)
- **GitHub CLI** — solicitar autorización en Service Central
- **PowerShell 7.0+** — solicitar autorización en Service Central
- **Node.js v22+** (disponible en el Marketplace de Fran)
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

---

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Marketplace y Plugins →](03-marketplace-plugins.md)
