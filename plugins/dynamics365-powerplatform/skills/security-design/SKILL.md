---
name: security-design
description: Diseña el modelo de seguridad completo para una solución Power Platform y Dataverse. Crea roles de seguridad con privilegios granulares, define Object Ownership Security (OWS), Column Security Profiles, Row-Level Security, políticas DLP y estrategia de entornos. Úsalo cuando el usuario necesite "modelo de seguridad", "roles dataverse", "permisos power platform", "dlp policy", "row level security", "column security", "quién puede ver qué".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires PAC CLI >= 2.3.1.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[descripción de la solución: roles de usuario, requisitos de privacidad, sensibilidad de datos]"
---

# Security Design

**Triggers**: security-design, modelo de seguridad, roles dataverse, permisos power platform, dlp policy, row level security
**Aliases**: /security, /security-design, /roles

## Referencias

- **ALM**: [alm-guidelines.md](../../references/alm-guidelines.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Verificar Entorno

```powershell
pac auth list
pac env who
```

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Cuáles son los roles de usuario del sistema?"** — Ej: Admin, Manager, Agent, ReadOnly, External User
2. **"¿Hay datos sensibles o confidenciales?"** — Ej: datos personales (GDPR), salarios, información médica
3. **"¿Los usuarios deben ver solo sus propios registros o también los del equipo?"** — Para diseñar OWS
4. **"¿Integración con sistemas externos (APIs)?"** — Para evaluar DLP
5. **"¿Requisitos normativos?"** — GDPR, ISO 27001, etc.

### Paso 3: Diseñar el Modelo de Seguridad

Presenta el diseño completo en `EnterPlanMode`:

```markdown
## Modelo de Seguridad: [Nombre de la Solución]

### Principios Aplicados
- **Mínimo privilegio**: Cada rol solo tiene los permisos necesarios para su función
- **Zero Trust**: No se asume confianza implícita; todo acceso es verificado
- **Defense in depth**: Múltiples capas de seguridad (OWS + Column Security + Business Unit)

---

### 1. Estructura de Business Units

```
Root Business Unit (Organización)
├── BU_Spain
│   ├── BU_Spain_Sales
│   └── BU_Spain_Service
└── BU_Portugal
    ├── BU_Portugal_Sales
    └── BU_Portugal_Service
```

Usa Business Units cuando haya separación organizacional real de datos.

---

### 2. Roles de Seguridad

#### Rol: src_SalesManager

**Propósito**: Gestores de ventas — acceso completo a oportunidades propias y del equipo

| Tabla | Create | Read | Write | Delete | Append | Append To |
|-------|--------|------|-------|--------|--------|-----------|
| Opportunity | User | Business Unit | User | User | User | User |
| Account | No | Organization | User | No | User | User |
| Contact | User | Business Unit | User | No | User | User |
| src_work_order | User | Business Unit | User | User | User | User |

*Niveles de acceso: No, User (solo propio), Business Unit, Parent: Child Business Units, Organization (todos)*

#### Rol: src_SalesAgent

**Propósito**: Agentes de ventas — acceso solo a sus propios registros

| Tabla | Create | Read | Write | Delete | Append | Append To |
|-------|--------|------|-------|--------|--------|-----------|
| Opportunity | User | User | User | No | User | User |
| Account | No | Organization | No | No | No | No |
| Contact | User | User | User | No | User | User |
| src_work_order | User | User | User | No | User | User |

#### Rol: src_ReadOnly

**Propósito**: Usuarios de solo lectura — informes y consultas

| Tabla | Create | Read | Write | Delete |
|-------|--------|------|-------|--------|
| Opportunity | No | Business Unit | No | No |
| Account | No | Organization | No | No |
| src_work_order | No | Business Unit | No | No |

---

### 3. Object Ownership Security (OWS)

**Ownership Model**: User-owned (recomendado para la mayoría de tablas)

```
Tabla src_work_order:
- Ownership: User-owned
- Jerarquía: Manager ve registros de sus subordinados
- Compartir: Permitido share a nivel User
```

**Team Ownership**: Para procesos donde el registro pertenece a un equipo, no a un usuario individual.

---

### 4. Column Security Profiles

Para columnas con datos sensibles:

#### Profile: src_ConfidentialFields

**Columnas protegidas**:
| Tabla | Columna | Read | Create | Update |
|-------|---------|------|--------|--------|
| Contact | `src_salary` | Solo HR Manager | Solo HR Manager | Solo HR Manager |
| Account | `src_credit_limit` | Solo Finance | Solo Finance | Solo Finance |
| src_work_order | `src_internal_notes` | Managers | Agents | Managers |

**Roles con acceso**: `src_HRManager`, `src_FinanceManager`

---

### 5. Row-Level Security — Field Security

Para escenarios avanzados donde OWS no es suficiente:

```csharp
// Plugin para implementar RLS personalizada
// Pre-retrieve: filtrar registros según reglas de negocio
// Útil cuando la lógica de visibilidad es más compleja que la jerarquía de BU
```

---

### 6. Políticas DLP (Data Loss Prevention)

**Entorno de Producción** — Política restrictiva:

| Conector | Clasificación | Justificación |
|---------|--------------|---------------|
| Dataverse | Business | Datos corporativos principales |
| Office 365 Outlook | Business | Email corporativo |
| SharePoint | Business | Documentos corporativos |
| Teams | Business | Comunicación interna |
| HTTP (genérico) | Blocked | Sin whitelist previa |
| Twitter/X | Non-Business | No uso corporativo |
| Todos los demás | Non-Business | Por defecto |

> ⚠️ Business y Non-Business no pueden mezclarse en el mismo flow.

---

### 7. Estrategia de Entornos

| Entorno | Tipo | Acceso | Managed Solutions |
|---------|------|--------|------------------|
| Development | Sandbox | Devs + Admins | No (Unmanaged) |
| Test | Sandbox | Devs + Testers | Sí (Managed) |
| UAT | Sandbox | Testers + Key Users | Sí (Managed) |
| Production | Production | Usuarios finales | Sí (Managed) |

**Reglas**:
- Nadie excepto el pipeline CI/CD puede importar soluciones a Test/UAT/Prod
- Los usuarios finales nunca tienen acceso a Development
- Las customizaciones en Production son bloqueadas (Managed Solution)

---

### 8. Checklist de Implementación

```powershell
# 1. Crear roles de seguridad via PAC CLI / Portal
pac solution add-reference --path ./security/

# 2. Verificar privilegios
pac admin list-role --environment [env-id]

# 3. Asignar roles a usuarios
pac admin assign-role --user [user-id] --role [role-id] --environment [env-id]

# 4. Configurar Column Security Profiles en el portal
# Settings > Security > Column Security Profiles

# 5. Revisar y exportar DLP policies
pac admin list-app-policies --environment [env-id]
```

---

### 9. Auditoría y Trazabilidad

- Habilitar **Audit Log** para tablas con datos sensibles
- Configurar **retention policy** según requisitos normativos
- Revisar logs con: `Settings > Auditing > Audit Summary View`
- Para GDPR: configurar Data Retention y Right to Erasure workflows
```

### Paso 4: Implementar con PAC CLI

```powershell
# Exportar configuración de seguridad para versionado
pac solution export --path ./solutions --name SecurityConfiguration --managed false

# Asignar roles en masa (ejemplo con PowerShell)
$users = @("user1@company.com", "user2@company.com")
foreach ($user in $users) {
    pac admin assign-user --user $user --role "src_SalesAgent" --environment [env-id]
}
```

### Paso 5: Resumen Final

- Modelo de seguridad completo diseñado
- Roles de seguridad con privilegios granulares
- Column Security Profiles para datos sensibles
- DLP policies definidas
- Estrategia de entornos documentada
- Próximos pasos: implementar en Dev, validar con escenarios de prueba, incluir en pipeline ALM (`/alm-pipeline`)
