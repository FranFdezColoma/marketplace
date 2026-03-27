---
name: pull-request
description: Crea una Pull Request con los últimos cambios del repositorio siguiendo las convenciones del proyecto. Gestiona el staging de ficheros, commit con Conventional Commits, push a rama y creación del PR con GitHub CLI (gh). Genera automáticamente un título y descripción estructurada. Úsalo cuando el usuario necesite "abre un pull request", "crea un pr", "sube los cambios", "commitea y abre pr", "pull request con los últimos cambios", "crea pr a main".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code. Requires git and gh CLI (GitHub CLI) authenticated with gh auth login.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[descripción del cambio; o 'todos los cambios' para hacer stage de todo]"
---

# Pull Request Builder

**Triggers**: pull-request, abre un pull request, crea un pr, sube los cambios, commitea y abre pr
**Aliases**: /pr, /pull-request, /open-pr

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
git --version                    # Git instalado
gh auth status                   # GitHub CLI autenticado
gh --version                     # GitHub CLI instalado
```

Si `gh auth status` falla, ejecutar:
```powershell
gh auth login
```

### Paso 2: Inspeccionar el Estado del Repositorio

```powershell
# Ver qué ha cambiado
git --no-pager status

# Ver el diff de los cambios
git --no-pager diff

# Ver también los cambios ya en staging
git --no-pager diff --staged
```

Lee el output cuidadosamente para:
- Entender qué ficheros han cambiado
- Agrupar los cambios de forma coherente para el commit
- Determinar el tipo de Conventional Commit adecuado

### Paso 3: Determinar el Tipo de Commit (Conventional Commits)

Usa la siguiente tabla para seleccionar el tipo correcto:

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat:` | Nueva funcionalidad o skill |
| `fix:` | Corrección de bug o incongruencia |
| `refactor:` | Mejora de código sin cambio de comportamiento |
| `docs:` | Cambios solo en documentación (README, AGENTS.md, etc.) |
| `chore:` | Cambios en configuración, dependencias, herramientas |
| `test:` | Añadir o mejorar tests |
| `style:` | Cambios de formato, espacios, etc. (sin cambio lógico) |
| `perf:` | Mejoras de rendimiento |

**Formato completo:**
```
<tipo>[scope opcional]: <descripción en imperativo, minúsculas, sin punto final>

[cuerpo opcional — explicación del "por qué"]

[footer opcional — BREAKING CHANGE, referencias a issues]
```

**Ejemplos válidos:**
```
feat(plugin-builder): add MSTest+Moq test template
fix(developer): replace FakeXrmEasy references with MSTest+Moq
docs(agents): add unit-test-builder and pull-request to skills table
chore(plugin): add agents and skills metadata to plugin.json
feat(skills): add unit-test-builder skill for C# and JS/TS tests
feat(skills): add pull-request skill for PR creation workflow
fix(pcf-builder): replace deprecated ReactDOM.render with createRoot
```

### Paso 4: Stage y Commit

```powershell
# Opción A — Stage de todos los cambios
git add .

# Opción B — Stage selectivo (recomendado para commits atómicos)
git add [ruta/fichero1] [ruta/fichero2]

# Opción C — Stage interactivo
git add -p

# Verificar qué va al commit
git --no-pager diff --staged

# Crear el commit
git commit -m "[tipo]([scope]): [descripción]"

# Si el commit necesita cuerpo largo, usa el editor:
# git commit  (abre editor, escribe el mensaje completo)
```

⚠️ **Antes de commitear, verifica:**
- Los ficheros staged son exactamente los que deben ir en este commit
- El mensaje sigue Conventional Commits
- No se incluyen secrets, credenciales ni ficheros generados (bin/, obj/, node_modules/)

### Paso 5: Push a Rama

```powershell
# Ver la rama actual
git --no-pager branch --show-current

# Si la rama no existe en remoto (primer push)
git push -u origin HEAD

# Si la rama ya existe en remoto
git push
```

### Paso 6: Crear la Pull Request

```powershell
# Ver las ramas disponibles para base
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

# Crear PR con título y descripción interactivos
gh pr create --title "[título del PR]" --body "[descripción]"

# Crear PR directo a la rama base (ej: main)
gh pr create \
  --title "[tipo]([scope]): [descripción corta]" \
  --body "$(cat << 'EOF'
## ¿Qué cambia este PR?

[Descripción breve de los cambios]

## ¿Por qué?

[Motivación o contexto del cambio]

## Cambios incluidos

- [Fichero o componente]: [qué cambia]
- [Fichero o componente]: [qué cambia]

## Cómo probar

1. [Paso 1]
2. [Paso 2]

## Checklist

- [ ] Los tests pasan (`dotnet test` / `npm test`)
- [ ] Solution Checker sin errores críticos
- [ ] La documentación está actualizada
- [ ] No hay secretos ni credenciales expuestos
EOF
)" \
  --base main
```

### Paso 7: Plantilla de descripción de PR

Cuando generes la descripción del PR, usa siempre esta estructura:

```markdown
## ¿Qué cambia este PR?

[2-3 líneas explicando el cambio principal]

## ¿Por qué?

[Motivación: bug corregido, funcionalidad nueva, refactorización necesaria]

## Cambios incluidos

- `ruta/fichero.cs`: descripción del cambio
- `ruta/SKILL.md`: descripción del cambio

## Cómo probar

1. [Instrucción concreta de verificación]
2. [Instrucción concreta de verificación]

## Issues relacionados

Closes #[número] / Fixes #[número] / Related to #[número]

## Checklist

- [ ] Tests pasan localmente
- [ ] No hay breaking changes (o están documentados)
- [ ] La documentación está actualizada
```

### Paso 8: Verificar que el PR fue creado

```powershell
# Ver el PR recién creado
gh pr view

# Abrir en el navegador
gh pr view --web

# Ver todos los PRs abiertos
gh pr list
```

---

## Flujo completo en un solo bloque

```powershell
# 1. Ver qué cambió
git --no-pager status

# 2. Stage de cambios (ajusta según lo que vayas a commitear)
git add .

# 3. Commit con Conventional Commits
git commit -m "feat(skills): add unit-test-builder and pull-request skills"

# 4. Push
git push -u origin HEAD

# 5. Crear PR
gh pr create \
  --title "feat(skills): add unit-test-builder and pull-request skills" \
  --body "Adds two new skills to the power-platform-dataverse plugin." \
  --base main

# 6. Verificar
gh pr view --web
```
