---
name: code-review
description: Revisa código Power Platform con análisis profundo y severidad estructurada. Analiza C# (plugins, Custom APIs), TypeScript (PCF, web resources), Power Automate flows y configuración de soluciones. Proporciona siempre el código corregido, no solo la descripción del problema. Úsalo cuando el usuario necesite "revisa el código", "code review", "analiza este plugin", "qué problemas tiene", "mejora este código", "qué está mal".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0"
  argument-hint: "[código o fichero a revisar; o 'review completo' para revisar todo el proyecto]"
---

# Code Review

**Triggers**: code-review, revisa el código, code review, analiza este plugin, qué problemas tiene, mejora este código
**Aliases**: /review, /code-review, /cr

## Referencias

- **Patrones**: [dataverse-patterns.md](../../references/dataverse-patterns.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Recopilar el Código a Revisar

Si el usuario no ha proporcionado el código:

```powershell
# Buscar ficheros C# en el proyecto
Get-ChildItem -Recurse -Include "*.cs" | Where-Object { $_.Name -notlike "*.generated.*" }

# Buscar ficheros TypeScript
Get-ChildItem -Recurse -Include "*.ts","*.tsx" | Where-Object { $_.FullName -notlike "*node_modules*" }
```

Lee el código antes de revisar. Entiende el propósito del fichero antes de hacer comentarios.

### Paso 2: Escala de Severidad

Usa siempre esta escala en todos tus comentarios:

| Emoji | Nivel | Descripción |
|-------|-------|-------------|
| 🔴 | **Crítico** | Bug, security issue, corrupción de datos, error de runtime garantizado, violación de prácticas obligatorias. **Debe corregirse antes del despliegue.** |
| 🟡 | **Mejora recomendada** | Rendimiento, mantenibilidad, violación de estándares importantes, code smell significativo. **Debería corregirse pronto.** |
| 🔵 | **Sugerencia** | Estilo, legibilidad, naming minors, optimizaciones opcionales. **Considera implementarlo en una refactorización futura.** |

### Paso 3: Checklist de Revisión por Tipo

#### C# — Plugins y Custom APIs

**🔴 Verificar obligatoriamente:**

- [ ] ¿El plugin implementa `IPlugin` directamente?
- [ ] ¿El método `Execute` delega la lógica a un handler/service separado?
- [ ] ¿Se usa `ITracingService` en todas las operaciones importantes?
- [ ] ¿Las excepciones de usuario se lanzan con `InvalidPluginExecutionException`?
- [ ] ¿Se valida la existencia de atributos con `.Contains()` o `.TryGetValue()` antes de acceder?
- [ ] ¿No hay llamadas a `RetrieveMultiple` dentro de bucles? (N+1 problem)
- [ ] ¿No hay hardcoded strings o magic numbers?
- [ ] ¿Los errores inesperados se capturan y re-lanzan con contexto?
- [ ] ¿No hay datos sensibles en los logs del tracing service?

**🟡 Verificar:**

- [ ] ¿Se usan Early Bound types o se accede directamente a atributos por string?
- [ ] ¿Los filtering attributes están configurados en el paso de registro?
- [ ] ¿Las operaciones pesadas son asíncronas?
- [ ] ¿El `ColumnSet` especifica solo las columnas necesarias?
- [ ] ¿Los métodos tienen una sola responsabilidad?
- [ ] ¿Las clases siguen el principio SRP de SOLID?

**🔵 Verificar:**
- [ ] ¿Los nombres de clases, métodos y variables son descriptivos?
- [ ] ¿Los comentarios explican el "por qué", no el "qué"?
- [ ] ¿Hay tests unitarios con MSTest + Moq?

#### TypeScript — PCF y Web Resources

**🔴 Verificar obligatoriamente:**

- [ ] ¿No se usa `Xrm.Page` (deprecado)? Debe usar `formContext`.
- [ ] ¿Todas las promesas tienen `try/catch` o `.catch()`?
- [ ] ¿No se usa `any` en TypeScript?
- [ ] ¿`"strict": true` en tsconfig?
- [ ] ¿No hay `var` — solo `const`/`let`?
- [ ] ¿Los event handlers se desregistran cuando ya no son necesarios?
- [ ] ¿No hay llamadas síncronas a la API en `OnLoad`?

**🟡 Verificar:**

- [ ] ¿El código está organizado en namespaces o módulos ES?
- [ ] ¿Las llamadas a la Web API están centralizadas en un servicio/helper?
- [ ] ¿Se usan `@types/xrm` para type safety?
- [ ] ¿Se implementa paginación en consultas que pueden devolver >5.000 registros?
- [ ] ¿El PCF gestiona correctamente `init`, `updateView` y `destroy`?

**🔵 Verificar:**
- [ ] ¿ESLint está configurado y los warnings están resueltos?
- [ ] ¿Prettier está configurado para formateo consistente?
- [ ] ¿Hay tests Jest para el componente?

#### Power Automate Flows

**🔴 Verificar obligatoriamente:**

- [ ] ¿El flow está asociado a una solución (no standalone)?
- [ ] ¿Los valores sensibles usan `Secure inputs/outputs`?
- [ ] ¿Todos los pasos críticos tienen gestión de errores (`Configure run after`)?
- [ ] ¿No hay credenciales o tokens hardcodeados en acciones?

**🟡 Verificar:**

- [ ] ¿El nombre sigue la convención `[Scope]_[Entity]_[Action]`?
- [ ] ¿Todos los valores configurables usan Variables de Entorno?
- [ ] ¿La lógica reutilizable está en Child Flows?
- [ ] ¿El trigger usa `Filter columns` para reducir ejecuciones innecesarias?
- [ ] ¿Las consultas Dataverse seleccionan solo las columnas necesarias?
- [ ] ¿Los bucles usan paginación si el volumen puede ser alto?

**🔵 Verificar:**
- [ ] ¿Todas las acciones tienen nombres descriptivos (no nombres por defecto)?
- [ ] ¿Las acciones complejas tienen notas/comentarios?
- [ ] ¿Hay Scopes para agrupar lógica relacionada?

### Paso 4: Formato de Resultado

Presenta los resultados de la revisión siempre con este formato:

```markdown
## Code Review: [Nombre del fichero/componente]

**Resumen**: [2-3 líneas sobre la calidad general del código]

### Problemas Encontrados

---

🔴 **[CRÍTICO] Título del problema** — `[FileName.cs:línea]`

**Problema**: Descripción del problema.

**Código actual**:
```csharp
// código problemático
```

**Código corregido**:
```csharp
// código correcto
```

**Por qué**: Explicación de por qué esto es un problema y cómo la corrección lo resuelve.

---

🟡 **[MEJORA] Título del problema** — `[FileName.cs:línea]`

[mismo formato]

---

🔵 **[SUGERENCIA] Título del problema** — `[FileName.cs:línea]`

[mismo formato]

---

### Resumen Final

| Severidad | Cantidad |
|-----------|---------|
| 🔴 Crítico | N |
| 🟡 Mejora | N |
| 🔵 Sugerencia | N |

**Veredicto**: ✅ Listo para merge | ⚠️ Requiere correcciones menores | ❌ Requiere correcciones críticas

**Próximos pasos**:
1. Corregir problemas críticos y mejoras indicadas
2. Ejecutar tests: `dotnet test` / `npm test`
3. Ejecutar Solution Checker antes del despliegue
```

### Paso 5: Generar el Código Corregido

Para cada problema 🔴 o 🟡, proporciona siempre el snippet de código corregido, no solo la descripción del problema.

Si el reviewer detecta patrones de problemas repetidos que indican necesidad de refactorización más amplia, indica claramente:
> ⚠️ **Refactorización sugerida**: Este módulo tiene [N] ocurrencias de [patrón problemático]. Considera una refactorización más amplia en lugar de correcciones puntuales.
