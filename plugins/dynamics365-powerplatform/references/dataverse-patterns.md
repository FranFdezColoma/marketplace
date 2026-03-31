# Dataverse Patterns — Mejores Prácticas (Fran)

Referencia de patrones y mejores prácticas para desarrollo pro code en Dataverse, Dynamics 365 y Power Platform.

---

## 1. Plugins C# — Patrones Esenciales

### Estructura de Plugin (Patrón Obligatorio)

```csharp
// Plugin: Solo orquestación, sin lógica de negocio
public class OrderValidationPlugin : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
        var service = serviceFactory.CreateOrganizationService(context.UserId);

        tracingService.Trace("{0}: Start", nameof(OrderValidationPlugin));

        try
        {
            new OrderValidationHandler(service, tracingService).Execute(context);
        }
        catch (InvalidPluginExecutionException) { throw; }
        catch (Exception ex)
        {
            tracingService.Trace("{0}: Error. {1}", nameof(OrderValidationPlugin), ex);
            throw new InvalidPluginExecutionException($"Error inesperado: {ex.Message}", ex);
        }
    }
}
```

### Acceso Seguro a Atributos

```csharp
// ✅ CORRECTO — Validar antes de acceder
if (target.TryGetAttributeValue<Money>("src_totalamount", out var amount) && amount != null)
{
    // Usar amount.Value
}

// ✅ CORRECTO — Contains check
if (target.Contains("src_status"))
{
    var status = target.GetAttributeValue<OptionSetValue>("src_status");
}

// ❌ INCORRECTO — Acceso sin validación (NullReferenceException)
var amount = target.GetAttributeValue<Money>("src_totalamount").Value;
```

### Operaciones en Lote (Anti-N+1)

```csharp
// ✅ CORRECTO — ExecuteMultiple para actualizaciones en lote
var requests = new ExecuteMultipleRequest
{
    Settings = new ExecuteMultipleSettings { ContinueOnError = false, ReturnResponses = false },
    Requests = new OrganizationRequestCollection()
};

foreach (var orderId in orderIds)
{
    requests.Requests.Add(new UpdateRequest
    {
        Target = new Entity("src_order", orderId) { ["src_status"] = new OptionSetValue(100001) }
    });
}
service.Execute(requests);

// ❌ INCORRECTO — Bucle con llamadas individuales (N+1 problem)
foreach (var orderId in orderIds)
{
    service.Update(new Entity("src_order", orderId) { ["src_status"] = new OptionSetValue(100001) });
}
```

### Retrieve con ColumnSet Mínimo

```csharp
// ✅ CORRECTO — Solo columnas necesarias
var account = service.Retrieve("account", accountId, 
    new ColumnSet("name", "emailaddress1", "telephone1"));

// ❌ INCORRECTO — Todas las columnas (rendimiento)
var account = service.Retrieve("account", accountId, new ColumnSet(true));
```

### FetchXML con Paginación

```csharp
// ✅ CORRECTO — Paginación en RetrieveMultiple
string fetchXml = $@"
<fetch count='5000' page='{pageNumber}' paging-cookie='{encodedCookie}'>
  <entity name='src_work_order'>
    <attribute name='src_work_orderid'/>
    <attribute name='src_name'/>
    <attribute name='src_status'/>
    <filter>
      <condition attribute='statuscode' operator='eq' value='1'/>
    </filter>
  </entity>
</fetch>";

var result = service.RetrieveMultiple(new FetchExpression(fetchXml));
// Procesar result.MoreRecords y result.PagingCookie para siguiente página
```

---

## 2. TypeScript / JavaScript — Patrones Esenciales

### Servicio Centralizado Web API

```typescript
// dataverseService.ts — Centraliza todas las llamadas a Dataverse
class DataverseService {
    private readonly webApi: Xrm.WebApi;
    
    constructor(webApi: Xrm.WebApi) {
        this.webApi = webApi;
    }
    
    async getAccountById(accountId: string): Promise<Xrm.WebApi.Entity> {
        return await this.webApi.retrieveRecord(
            "account",
            accountId,
            "?$select=name,emailaddress1,telephone1,revenue"
        );
    }
    
    async getActiveOpportunities(
        accountId: string,
        pageSize: number = 50
    ): Promise<Xrm.WebApi.RetrieveMultipleResult> {
        return await this.webApi.retrieveMultipleRecords(
            "opportunity",
            `?$select=name,estimatedvalue,statuscode&$filter=_accountid_value eq ${accountId} and statecode eq 0&$top=${pageSize}&$orderby=estimatedvalue desc`
        );
    }
}
```

### Paginación en TypeScript

```typescript
async function* getAllRecords<T>(
    entityName: string,
    query: string,
    pageSize: number = 5000
): AsyncGenerator<T[]> {
    let nextPageLink: string | undefined = `${entityName}?${query}&$top=${pageSize}`;
    
    while (nextPageLink) {
        const result = await Xrm.WebApi.retrieveMultipleRecords(entityName, nextPageLink);
        yield result.entities as T[];
        nextPageLink = result.nextLink ? new URL(result.nextLink).search : undefined;
    }
}
```

### Form Script con Error Handling

```typescript
namespace Fran.Sales.Opportunity {
    export async function onFormLoad(
        executionContext: Xrm.Events.EventContext
    ): Promise<void> {
        const formContext = executionContext.getFormContext();
        
        try {
            await Promise.all([
                loadRelatedData(formContext),
                configureFieldVisibility(formContext)
            ]);
        } catch (error) {
            console.error("Error in onFormLoad:", error);
            formContext.ui.setFormNotification(
                "Error al cargar datos. Por favor, recarga la página.",
                "ERROR",
                "loadError"
            );
        }
    }
    
    async function loadRelatedData(formContext: Xrm.FormContext): Promise<void> {
        const accountRef = formContext.getAttribute("accountid")?.getValue()?.[0];
        if (!accountRef) return;
        
        const service = new DataverseService(Xrm.WebApi);
        const account = await service.getAccountById(accountRef.id);
        
        // Update form fields with account data
        formContext.getAttribute("description")?.setValue(`Account revenue: ${account.revenue}`);
    }
}
```

---

## 3. PCF Control — Patrón Lifecycle

```typescript
export class src_MyControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _container: HTMLDivElement;
    private _notifyOutputChanged: () => void;
    private _context: ComponentFramework.Context<IInputs>;

    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._container = container;
        this._notifyOutputChanged = notifyOutputChanged;
        this._context = context;
        
        this._render(context);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this._context = context;
        this._render(context);
    }

    public getOutputs(): IOutputs {
        return { /* outputs */ };
    }

    public destroy(): void {
        ReactDOM.unmountComponentAtNode(this._container);
    }

    private _render(context: ComponentFramework.Context<IInputs>): void {
        const props = {
            value: context.parameters.value.raw,
            isDisabled: context.mode.isControlDisabled,
            onChange: this._handleChange.bind(this)
        };
        
        ReactDOM.render(React.createElement(MyComponent, props), this._container);
    }

    private _handleChange(newValue: unknown): void {
        this._notifyOutputChanged();
    }
}
```

---

## 4. Dataverse API — Patrones OData

### Consultas OData Eficientes

```typescript
// ✅ CORRECTO — Select específico, filter, orderby, top
const url = "accounts?$select=name,emailaddress1&$filter=statecode eq 0 and revenue gt 100000&$orderby=name asc&$top=50";

// ✅ Expand con select (evitar expand sin select)
const url = "opportunities?$select=name,estimatedvalue&$expand=account($select=name,revenue)";

// ❌ INCORRECTO — Sin $select (trae todas las columnas)
const url = "accounts?$filter=statecode eq 0";
```

### Operaciones CRUD Web API

```typescript
// Create
const newAccount = await Xrm.WebApi.createRecord("account", {
    name: "New Account",
    emailaddress1: "contact@example.com",
    "primarycontactid@odata.bind": `/contacts(${contactId})`  // Lookup via odata.bind
});

// Update (PATCH)
await Xrm.WebApi.updateRecord("account", accountId, {
    name: "Updated Name",
    revenue: 500000
});

// Delete
await Xrm.WebApi.deleteRecord("account", accountId);

// Associate (N:N relationship)
await Xrm.WebApi.associateRecords(
    "account", accountId,
    "contact_customer_accounts",
    "contact", contactId
);
```

---

## 5. Seguridad — Patrones

### Principio de Mínimo Privilegio

```
Regla: Un rol de seguridad solo debe tener exactamente los privilegios que necesita.

Proceso de diseño:
1. Identifica las tablas que el rol debe acceder
2. Define el scope (User, Business Unit, Organization) por tabla
3. Define las operaciones (Create/Read/Write/Delete/Append/AppendTo/Assign/Share)
4. Empieza con acceso cero y añade solo lo necesario
5. Prueba con un usuario real en el rol antes de desplegar
```

### Datos Sensibles — Column Security

```
Columnas que SIEMPRE deben tener Column Security:
- Salarios, compensaciones
- Datos bancarios o financieros confidenciales  
- Datos médicos o de salud
- Contraseñas o secrets (no deben estar en Dataverse)
- Datos de identidad sensibles (NIF/NIE, pasaportes)
- Información legal confidencial
```

---

## 6. ALM — Patrones de Despliegue

### Managed vs Unmanaged Solutions

| Entorno | Tipo de Solution | Razón |
|---------|-----------------|-------|
| Development | Unmanaged | Permite edición directa |
| Test | Managed | Simula producción, no editable directamente |
| UAT | Managed | Igual que producción |
| Production | Managed | Protege las customizaciones |

### Versionado de Soluciones (SemVer adaptado)

```
Major.Minor.Patch.Build
1.0.0.0 → Primera release
1.1.0.0 → Nueva funcionalidad (backwards compatible)
1.1.1.0 → Bug fix
1.1.1.42 → Build number (automático en CI/CD)
```

---

## 7. Performance — Patrones

### Cuándo usar Síncrono vs Asíncrono en Plugins

| Escenario | Recomendación | Razón |
|-----------|--------------|-------|
| Validación de datos | Síncrono (Pre-operation) | Necesita bloquear la operación |
| Actualización de campos derivados | Síncrono (Post-operation) | Debe completarse en la misma transacción |
| Notificaciones, emails | Asíncrono | No bloquea al usuario, no necesita ser en tiempo real |
| Sincronización con sistemas externos | Asíncrono | Las llamadas externas no deben bloquear Dataverse |
| Operaciones pesadas (reports, batch) | Asíncrono o Azure Function | Evita timeouts de 2 minutos |

### Límites de la Plataforma (API Limits)

```
- Requests por usuario por minuto: 120.000 (por defecto, varía por licencia)
- Plugin timeout: 2 minutos (síncrono), 10 minutos (asíncrono)
- ExecuteMultiple max batch size: 1.000 operaciones
- RetrieveMultiple max records: 5.000 por página
- FetchXML max aggregate rows: 50.000
- Power Automate: 100.000 acciones por mes (por licencia)
```
