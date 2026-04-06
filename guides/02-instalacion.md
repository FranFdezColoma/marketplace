# 2. Instalación y primeros pasos

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Marketplace y Plugins →](03-marketplace-plugins.md)

---

## 📋 Prerrequisitos

Antes de instalar el CLI es necesario completar los siguientes pasos **en orden**. Saltarse alguno es la causa más habitual de problemas durante la instalación.

---

### 🎫 Paso 1 — Solicitar la licencia de GitHub Copilot

La licencia se solicita a través de **Service Central**. Para abrir la solicitud necesitas un **código de proyecto** válido.

> ⏳ El proceso de aprobación puede tardar unos días laborables. Inicia la solicitud con antelación.

---

### 📧 Paso 2 — Acceder al portal de registro tras la aprobación

Una vez aprobada la solicitud, recibirás un **correo de confirmación** con un enlace a un SharePoint de Capgemini.

1. Abre el enlace del correo (o navega directamente al [portal de registro de GitHub Copilot](https://capgemini.sharepoint.com/sites/IN_Europe_IndusSharedServices/SitePages/MS-GitHub-Copilot-Usage-Registration.aspx))
2. Baja hasta la sección **"How to integrate GitHub Copilot with IDE"**
3. Ahí encontrarás el enlace a la instancia EMU de GitHub Copilot de Capgemini

---

### 🔐 Paso 3 — Activar la cuenta en el EMU de GitHub

> ⚠️ Si tienes una sesión de GitHub abierta en el navegador, **ciérrala primero** antes de continuar.

1. Haz clic en el enlace **GitHub Copilot EMU Instance** del portal de registro
2. El navegador te redirigirá al SSO de Capgemini — inicia sesión con tu cuenta corporativa
3. Una vez dentro, ya tienes acceso a GitHub a través de la cuenta corporativa

---

### ✅ Paso 4 — Verificar que tienes la licencia activa

Antes de continuar, confirma que la licencia está correctamente asignada:

1. Ve a [github.com](https://github.com) y asegúrate de estar con la sesión de la cuenta corporativa (EMU)
2. Abre **Settings → Your plan**
3. Deberías ver que es una cuenta **Business** con **premium requests** disponibles

Si no aparece nada o muestra una cuenta gratuita, contacta con el equipo de soporte antes de continuar.

---

### 🖥️ Paso 5 — Instalar GitHub CLI y PowerShell 7+

GitHub Copilot CLI es una **extensión de GitHub CLI**, por lo que ambos son necesarios.

> ⚠️ **Importante:** GitHub CLI y PowerShell 7+ **no están en el marketplace de software de Capgemini**. No basta con descargar el instalador manualmente y pedir aprobación. Es obligatorio abrir un **ticket en Service Central** solicitando su instalación.

Abre un ticket en Service Central indicando que necesitas instalar:

- **GitHub CLI** (`gh`)
- **PowerShell 7.0 o superior**

Una vez que tengas ambos instalados, verifica que funcionan correctamente:

```powershell
gh --version        # Debe mostrar: gh version 2.x.x
$PSVersionTable.PSVersion  # Debe ser 7.x.x o superior
```

> 💡 **¿Dónde ejecuto estos comandos?** En **PowerShell** — ya sea el terminal integrado de VS Code (`Ctrl+ñ`) o una ventana de PowerShell independiente. Ambos funcionan igual.

---

### 📦 Paso 6 — Instalar GitHub Copilot CLI

Con GitHub CLI instalado, instala GitHub Copilot CLI mediante WinGet:

```powershell
winget install GitHub.Copilot
```

Verifica la instalación:

```powershell
copilot --version
```

---

## 🔑 Autenticación

> ❓ **¿Con qué cuenta me logueo?** Con **github.com** — es decir, la cuenta EMU corporativa que activaste en el Paso 3. **No** uses GitHub Enterprise Cloud.

Navega a la carpeta de tu proyecto y lanza el CLI:

```powershell
cd C:\Proyectos\MiProyecto
copilot
```

La primera vez te preguntará si confías en el directorio:

```
? Do you trust the files in this folder?
  ❯ Trust (for this session)
    Trust (always)
    Don't trust
```

Si es la primera vez o el token ha expirado, ejecuta `/login`:

```
> /login
# 1. El CLI muestra un código de un solo uso (ej: ABCD-1234)
# 2. Se abre el navegador en github.com/login/device
# 3. Introduce el código → Authorize
# 4. Vuelve al terminal — ya estás autenticado
```

> 🔒 El login persiste entre sesiones. Solo necesitas hacerlo una vez.

---

## ❓ Preguntas frecuentes de instalación

| Pregunta | Respuesta |
|----------|-----------|
| ¿En qué terminal ejecuto los comandos? | En **PowerShell** — desde el terminal de VS Code o una ventana independiente |
| ¿Con qué cuenta me logueo en GitHub? | Con tu cuenta **github.com** corporativa (EMU), no con GitHub Enterprise Cloud |
| El comando `copilot` no se reconoce | Reinicia PowerShell después de instalar con WinGet |
| Me pide login cada vez que abro el terminal | Asegúrate de hacer clic en "Trust (always)" la primera vez |
| No veo las premium requests en GitHub Settings | El ticket de Service Central puede estar pendiente; espera la confirmación |

---

[← Anterior: ¿Qué es Copilot CLI?](01-que-es.md) | [Siguiente: Marketplace y Plugins →](03-marketplace-plugins.md)
