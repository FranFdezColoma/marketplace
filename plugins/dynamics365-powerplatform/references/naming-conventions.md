# Naming Conventions — Power Platform & Dataverse (Capgemini)

Referencia estándar de nomenclatura para todos los artefactos desarrollados por Capgemini en Microsoft Power Platform, Dataverse y Dynamics 365.

**Publisher prefix de ejemplo**: `src_`

---

## 1. Dataverse — Tablas y Columnas

### Tablas Personalizadas (Custom Tables)

| Patrón | Formato | Ejemplo |
|--------|---------|---------|
| Nombre lógico | `{prefix}_{entity_name}` — snake_case | `src_work_order`, `src_customer_profile` |
| Display Name | Title Case | "Work Order", "Customer Profile" |
| Plural Display Name | Title Case + "s" | "Work Orders", "Customer Profiles" |

**Reglas**:
- Usa siempre el prefijo del publisher (`src_`, o el prefijo del cliente)
- Solo letras minúsculas y guiones bajos en el nombre lógico
- El display name puede tener spaces y Title Case

### Tablas Estándar Reutilizadas

No se modifica el nombre. Se usan tal cual: `account`, `contact`, `opportunity`, `systemuser`, `team`.

### Columnas Personalizadas

| Tipo de columna | Formato | Ejemplo |
|-----------------|---------|---------|
| Texto, número, fecha | `{prefix}_{columnname}` | `src_work_order_number`, `src_total_cost` |
| Lookup a otra tabla | `{prefix}_{referencedentity}id` | `src_accountid`, `src_work_orderid` |
| Choice/Option Set | `{prefix}_{columnname}` | `src_status`, `src_priority` |
| Boolean (Two Options) | `{prefix}_{columnname}` | `src_is_active`, `src_requires_approval` |

**Reglas**:
- Solo minúsculas y guiones bajos
- El nombre debe ser descriptivo y expresar su propósito
- Evita abreviaturas poco claras (`src_ttl_amt` → usa `src_total_amount`)

### Relaciones N:N

| Patrón | Ejemplo |
|--------|---------|
| `{prefix}_{entity1}_{prefix}_{entity2}` | `src_contact_src_project` |

---

## 2. Componentes PCF (PowerApps Component Framework)

| Artefacto | Formato | Ejemplo |
|-----------|---------|---------|
| Nombre del control | `{Publisher}_{ControlName}` — PascalCase | `src_CustomerRating`, `src_MapViewer` |
| Namespace | `{Company}.{Domain}` — PascalCase | `Capgemini.Sales` |
| Fichero TypeScript principal | `index.ts` | `index.ts` |
| Componentes React | PascalCase + `Component` | `CustomerRatingComponent.tsx` |
| Servicios/helpers | camelCase + `Service`/`Helper` | `dataverseService.ts`, `formatHelper.ts` |
| Tests | `[nombreFichero].test.ts(x)` | `CustomerRatingComponent.test.tsx` |
| Interfaces | `I` + PascalCase | `ICustomerRating`, `IDataverseService` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RATING_VALUE`, `DEFAULT_PAGE_SIZE` |

---

## 3. Plugins C# y Custom APIs

### Clases y Archivos

| Artefacto | Formato | Ejemplo |
|-----------|---------|---------|
| Plugin class | `{EntityPascal}{Action}Plugin` | `OpportunityValidatePlugin` |
| Handler class | `{EntityPascal}{Action}Handler` | `OpportunityValidateHandler` |
| Service class | `{Domain}Service` | `OrderCalculationService` |
| Custom API handler | `{ApiName}Handler` | `CalculateOrderTotalHandler` |
| Test class | `{ClassUnderTest}Tests` | `OpportunityValidateHandlerTests` |
| Test method | `{Method}_{State}_{Expected}` | `Execute_WhenAmountIsNegative_ThrowsException` |

### Nomenclatura C#

| Elemento | Formato | Ejemplo |
|----------|---------|---------|
| Clases | PascalCase | `OrderCalculationService` |
| Métodos | PascalCase | `CalculateTotalAmount` |
| Propiedades | PascalCase | `TotalAmount` |
| Interfaces | `I` + PascalCase | `IOrderCalculationService` |
| Variables locales | camelCase | `totalAmount` |
| Parámetros | camelCase | `orderEntity` |
| Campos privados | `_` + camelCase | `_tracingService`, `_organizationService` |
| Constantes | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `PLUGIN_NAME` |

---

## 4. TypeScript / JavaScript

### Variables y Funciones

| Elemento | Formato | Ejemplo |
|----------|---------|---------|
| Variables | camelCase | `totalAmount`, `accountId` |
| Funciones | camelCase | `calculateTotal()`, `fetchAccounts()` |
| Clases | PascalCase | `OrderService`, `AccountRepository` |
| Interfaces | PascalCase (sin `I` en TS moderno) | `OrderData`, `AccountResponse` |
| Tipos | PascalCase | `OrderStatus`, `ApiResponse<T>` |
| Enums | PascalCase (valores también) | `OrderStatus.Pending`, `Priority.High` |
| Constantes (módulo) | `UPPER_SNAKE_CASE` | `MAX_PAGE_SIZE`, `DEFAULT_TIMEOUT_MS` |
| Ficheros de componentes | PascalCase | `CustomerCard.tsx` |
| Ficheros de servicios | camelCase | `customerService.ts` |
| Ficheros de utilidades | camelCase | `dateFormatter.ts` |

### Namespaces Web Resources

```typescript
namespace Capgemini.Sales.Opportunity {
    export async function onFormLoad(executionContext: Xrm.Events.EventContext): Promise<void> { }
}
```

Patrón: `{Company}.{Module}.{Entity}` — PascalCase

---

## 5. Power Automate Flows

| Elemento | Formato | Ejemplo |
|----------|---------|---------|
| Nombre del flow | `[Scope]_[Entity]_[Action]` | `Sales_Opportunity_NotifyOnWin` |
| Child flow | `Shared_[Domain]_[Action]` | `Shared_Email_SendNotification` |
| Variable | `var` + PascalCase | `varOpportunityId`, `varOwnerEmail` |
| Variable de entorno | `env_` + PascalCase | `env_NotificationEmail`, `env_ApprovalTimeout` |
| Nombre de acción | Descriptivo en inglés | "Get Opportunity Details", "Send Approval Email" |
| Nombre de scope | Descriptivo en inglés | "Scope: GetRelatedData", "Scope: HandleErrors" |

---

## 6. Soluciones Power Platform

| Elemento | Formato | Ejemplo |
|----------|---------|---------|
| Nombre de solución | PascalCase + dominio | `CapgeminiSalesCore`, `CustomerServiceModule` |
| Publisher | PascalCase | `Capgemini` |
| Publisher prefix | minúsculas (3-8 chars) | `src`, `cap`, `cgm` |
| Versión | SemVer `Major.Minor.Patch.Build` | `1.0.0.0`, `2.3.1.0` |

---

## 7. Git y Control de Versiones

### Ramas

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Feature | `feat/descripcion-kebab-case` | `feat/opportunity-validation-plugin` |
| Bug fix | `fix/descripcion-kebab-case` | `fix/pcf-render-on-mobile` |
| Release | `release/vX.Y.Z` | `release/v1.2.0` |
| Hotfix | `hotfix/descripcion` | `hotfix/plugin-null-reference` |

### Conventional Commits

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore, ci
Scope: plugin, pcf, flow, solution, docs, alm

Ejemplos:
feat(plugin): add order validation for negative amounts
fix(pcf): resolve null reference in CustomerRating updateView
docs(api): add OpenAPI spec for CalculateOrderTotal
ci(alm): add solution checker to GitHub Actions pipeline
```

---

## 8. Documentación

| Documento | Naming | Ubicación |
|-----------|--------|-----------|
| README principal | `README.md` | Raíz del repo |
| ADR | `ADR-[N]-[titulo-kebab].md` | `docs/adr/` |
| API Reference | `[api-name].md` | `docs/api/` |
| How-to Guide | `how-to-[tarea-kebab].md` | `docs/guides/` |
| Runbook | `runbook-[operacion-kebab].md` | `docs/runbooks/` |
| CHANGELOG | `CHANGELOG.md` | Raíz del repo |
