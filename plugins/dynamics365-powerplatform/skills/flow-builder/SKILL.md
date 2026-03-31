---
name: flow-builder
description: Crea un Power Automate flow de calidad productiva. Genera la especificación completa del flow con naming conventions, variables de entorno, child flows para lógica reutilizable, gestión de errores con Scopes, rendimiento optimizado y seguridad. Úsalo cuando el usuario necesite "crea un flow", "power automate", "automatiza este proceso", "flujo de aprobación", "notificación automática", "sincronización de datos", "trigger dataverse".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires PAC CLI >= 2.3.1.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[descripción del proceso a automatizar: trigger, acciones, lógica de negocio]"
---

# Power Automate Flow Builder

**Triggers**: flow-builder, crea un flow, power automate, automatiza, flujo de aprobación, notificación automática
**Aliases**: /flow, /flow-builder, /automate

## Referencias

- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)
- **ALM**: [alm-guidelines.md](../../references/alm-guidelines.md)

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
pac auth list
pac env who
```

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Cuál es el trigger del flow?"** — Dataverse row created/updated/deleted, schedule, HTTP request, Teams message, etc.
2. **"¿Qué proceso automatiza?"** — Descripción del proceso de negocio
3. **"¿Qué datos fluyen?"** — Entidades Dataverse, usuarios, sistemas externos involucrados
4. **"¿Hay lógica condicional?"** — Condiciones, bucles, aprobaciones
5. **"¿Cuántos registros procesa?"** — Para evaluar si necesita paginación o procesamiento asíncrono
6. **"¿Qué acciones realiza?"** — Crear/actualizar Dataverse, enviar email, Teams, HTTP calls, etc.

### Paso 3: Diseñar el Flow

#### Nomenclatura Obligatoria

```
Nombre del flow: [Scope]_[Entity]_[Action]
Ejemplos:
- Sales_Opportunity_NotifyOnWin
- Service_Case_EscalateOnTimeout
- HR_Employee_SendWelcomeEmail
- Finance_Invoice_SyncToERP
```

#### Checklist de Calidad

Antes de diseñar, define todos estos elementos:

- [ ] **Nombre**: `[Scope]_[Entity]_[Action]` en la solución correcta
- [ ] **Variables de entorno**: URLs, IDs, umbrales configurables identificados
- [ ] **Child Flows**: Lógica reutilizable candidata a child flow
- [ ] **Filtros del trigger**: Solo campos relevantes en `Filter columns`
- [ ] **Columnas seleccionadas**: Solo campos necesarios en consultas Dataverse
- [ ] **Scopes de error**: Cada bloque crítico envuelto en Scope con `Configure run after`
- [ ] **Propiedad del flow**: Service principal o cuenta de servicio para producción
- [ ] **Secure inputs/outputs**: Valores sensibles marcados como seguros

### Paso 4: Generar la Especificación del Flow

Presenta el diseño completo en `EnterPlanMode`:

```markdown
## Flow: [Scope]_[Entity]_[Action]

**Trigger**: When a row is created/modified (Dataverse)
**Tabla**: [entity_logical_name]
**Filter columns**: [columnas que activan el trigger]
**Run as**: Service Account / Calling User

---

### Variables de Entorno Necesarias
| Nombre | Tipo | Valor por defecto | Descripción |
|--------|------|-------------------|-------------|
| `env_NotificationEmail` | String | admin@company.com | Email para notificaciones |
| `env_ApprovalTimeout` | Integer | 48 | Horas para timeout de aprobación |

---

### Estructura del Flow

**1. Trigger: When a row is modified (Dataverse)**
- Table: `opportunity`
- Filter columns: `statuscode, estimatedvalue`

**2. Initialize Variables** (scope: Variables)
- `varOpportunityId` = triggerBody()?['opportunityid']
- `varOwnerEmail` = triggerBody()?['_ownerid_value@OData.Community.Display.V1.FormattedValue']

**3. Scope: GetRelatedData**
- Action: Get row (Dataverse) — Account relacionado
  - Table: accounts
  - Row ID: `@{triggerBody()?['_accountid_value']}`
  - Select columns: `name, emailaddress1, telephone1`
  
*Configure run after: Success*
*On failure → Scope: HandleErrors*

**4. Condition: Is Won?**
- `@equals(triggerBody()?['statuscode'], 3)` (3 = Won)

**4a. If Yes — Scope: ProcessWon**
- Action: Send email (Outlook)
  - To: `@{variables('varOwnerEmail')}`
  - Subject: `Oportunidad ganada: @{triggerBody()?['name']}`
  - Body: Template with opportunity details
- Action: Update row (Dataverse) — Marcar como procesado
  - Table: opportunities
  - Row ID: `@{variables('varOpportunityId')}`
  - `src_notificationsent`: true

**4b. If No — Terminate** (o lógica alternativa)

**5. Scope: HandleErrors**
- Action: Send email — Error notification to admin
- Action: Terminate (Failed) — with error details

---

### Child Flows Identificados

Si la lógica de notificación se repite en múltiples flows:
- **Child Flow**: `Shared_Email_SendNotification`
  - Input: `recipientEmail`, `subject`, `body`
  - Uso: llamado desde Sales_Opportunity_NotifyOnWin, Service_Case_EscalateOnTimeout, etc.

---

### Notas de Rendimiento

- Trigger con `Filter columns` para evitar ejecuciones innecesarias.
- Solo columnas necesarias en `Select columns` de las consultas.
- Paginación activada si el bucle procesa >5.000 registros.
- Concurrencia en `Apply to each` si el orden no importa y el volumen es alto.

---

### Notas de Seguridad

- Flow propiedad de service account en producción (no de un usuario individual).
- Valores sensibles (tokens, passwords) en Variables de Entorno marcadas como Secret.
- Revisar periódicamente los permisos de las conexiones usadas.
```

### Paso 5: Crear en Power Automate

Guía al usuario para crear el flow:

```powershell
# Exportar la solución para incluir el flow
pac solution export --path ./solutions/[SolutionName] --name [SolutionName] --managed false

# Importar en otro entorno
pac solution import --path ./solutions/[SolutionName]_[Version].zip --environment [TargetEnvironment]
```

**En Power Automate portal**:
1. Ve a `make.powerautomate.com`
2. Navega a la solución correcta
3. Crea el flow con los detalles del plan
4. Configura las variables de entorno
5. Activa el flow y verifica con un registro de prueba

### Paso 6: Verificar y Documentar

Tras crear el flow:

```powershell
# Listar flows en la solución
pac solution list
```

Genera documentación del flow con `/doc-generator`.

### Paso 7: Resumen Final

- Especificación completa del flow generada
- Variables de entorno identificadas
- Child flows candidatos identificados
- Próximos pasos: crear en Power Automate, configurar variables de entorno, añadir a pipeline ALM (`/alm-pipeline`)
