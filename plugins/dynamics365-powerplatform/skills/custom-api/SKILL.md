---
name: custom-api
description: Define y crea una Custom API en Dataverse con su handler C# completo. Genera la definición de la Custom API (parámetros entrada/salida, binding type), el plugin handler, la documentación OpenAPI y los comandos PAC CLI para registro. Úsalo cuando el usuario necesite "crea una custom api", "custom action reutilizable", "operación personalizada dataverse", "api personalizada", "endpoint dataverse", "business operation".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires dotnet >= 6.0 and PAC CLI >= 2.3.1.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[nombre y descripción de la operación: qué hace, inputs, outputs]"
---

# Custom API Builder

**Triggers**: custom-api, crea una custom api, api personalizada, operación personalizada dataverse, endpoint dataverse
**Aliases**: /api, /custom-api, /dataverse-api

## Referencias

- **Patrones**: [dataverse-patterns.md](../../references/dataverse-patterns.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
pac auth list
dotnet --version
```

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Cuál es el nombre de la operación?"** — Ej: `CalculateOrderTotal`, `ProcessRefund`
2. **"¿Es una función (GET) o acción (POST)?"** — Function si es idempotente y no modifica datos; Action si modifica estado
3. **"¿A qué se vincula (binding)?"** — Global (sin entidad), Entity (un registro) o EntityCollection (múltiples registros)
4. **"¿Qué parámetros recibe (inputs)?"** — Nombre, tipo, si es requerido
5. **"¿Qué devuelve (outputs)?"** — Nombre, tipo de respuesta
6. **"¿Qué lógica implementa?"** — Descripción del proceso de negocio

### Paso 3: Diseñar la Custom API

Presenta el diseño en `EnterPlanMode`:

```markdown
## Custom API: src_CalculateOrderTotal

**Tipo**: Action (POST) — modifica datos
**Binding**: Entity (opportunity) — opera sobre un registro

### Parámetros de Entrada
| Nombre | Tipo | Requerido | Descripción |
|--------|------|-----------|-------------|
| `IncludeTax` | Boolean | No | Incluir impuestos en el cálculo |
| `DiscountPercentage` | Decimal | No | Porcentaje de descuento a aplicar |

### Parámetros de Salida
| Nombre | Tipo | Descripción |
|--------|------|-------------|
| `TotalAmount` | Decimal | Importe total calculado |
| `TaxAmount` | Decimal | Importe de impuestos |
| `DiscountAmount` | Decimal | Importe del descuento |
| `IsSuccess` | Boolean | Si el cálculo fue exitoso |
| `ErrorMessage` | String | Mensaje de error (si aplica) |

### Invocación desde TypeScript (Web API)
POST [org]/api/data/v9.2/opportunities([id])/Microsoft.Dynamics.CRM.src_CalculateOrderTotal
```

### Paso 4: Crear la Custom API con PAC CLI

```powershell
# Crear la Custom API
pac customapi create `
    --name "src_CalculateOrderTotal" `
    --display-name "Calculate Order Total" `
    --description "Calculates the total amount for an opportunity including taxes and discounts" `
    --binding-type "Entity" `
    --bound-entity-logical-name "opportunity" `
    --is-function false `
    --allowed-customization-level 2

# Añadir parámetros de entrada
pac customapi add-request-param `
    --name "IncludeTax" `
    --display-name "Include Tax" `
    --type Boolean `
    --is-optional true `
    --customapi-name "src_CalculateOrderTotal"

pac customapi add-request-param `
    --name "DiscountPercentage" `
    --display-name "Discount Percentage" `
    --type Decimal `
    --is-optional true `
    --customapi-name "src_CalculateOrderTotal"

# Añadir parámetros de salida
pac customapi add-response-prop `
    --name "TotalAmount" `
    --display-name "Total Amount" `
    --type Decimal `
    --customapi-name "src_CalculateOrderTotal"

pac customapi add-response-prop `
    --name "IsSuccess" `
    --display-name "Is Success" `
    --type Boolean `
    --customapi-name "src_CalculateOrderTotal"

pac customapi add-response-prop `
    --name "ErrorMessage" `
    --display-name "Error Message" `
    --type String `
    --customapi-name "src_CalculateOrderTotal"
```

### Paso 5: Generar el Plugin Handler

```csharp
// CalculateOrderTotalHandler.cs
using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Fran.Sales
{
    /// <summary>
    /// Plugin handler for Custom API: src_CalculateOrderTotal
    /// Bound to: opportunity (Entity)
    /// Type: Action (POST)
    /// </summary>
    public class CalculateOrderTotalHandler : IPlugin
    {
        // Input parameter names (must match Custom API definition)
        private const string INPUT_INCLUDE_TAX = "IncludeTax";
        private const string INPUT_DISCOUNT_PERCENTAGE = "DiscountPercentage";

        // Output parameter names (must match Custom API definition)
        private const string OUTPUT_TOTAL_AMOUNT = "TotalAmount";
        private const string OUTPUT_TAX_AMOUNT = "TaxAmount";
        private const string OUTPUT_DISCOUNT_AMOUNT = "DiscountAmount";
        private const string OUTPUT_IS_SUCCESS = "IsSuccess";
        private const string OUTPUT_ERROR_MESSAGE = "ErrorMessage";

        private const decimal TAX_RATE = 0.21m; // 21% IVA

        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = serviceFactory.CreateOrganizationService(context.UserId);

            tracingService.Trace("CalculateOrderTotalHandler: Start. Target Id={0}", context.PrimaryEntityId);

            try
            {
                // Read input parameters
                var includeTax = context.InputParameters.TryGetValue(INPUT_INCLUDE_TAX, out var taxParam)
                    && (bool)taxParam;
                var discountPct = context.InputParameters.TryGetValue(INPUT_DISCOUNT_PERCENTAGE, out var discParam)
                    ? (decimal)discParam : 0m;

                // Retrieve the opportunity
                var opportunity = service.Retrieve(
                    "opportunity",
                    context.PrimaryEntityId,
                    new ColumnSet("estimatedvalue", "name"));

                var baseAmount = opportunity.GetAttributeValue<Money>("estimatedvalue")?.Value ?? 0m;
                tracingService.Trace("Base amount: {0}, Include tax: {1}, Discount: {2}%",
                    baseAmount, includeTax, discountPct);

                // Calculate
                var discountAmount = baseAmount * (discountPct / 100m);
                var amountAfterDiscount = baseAmount - discountAmount;
                var taxAmount = includeTax ? amountAfterDiscount * TAX_RATE : 0m;
                var totalAmount = amountAfterDiscount + taxAmount;

                // Set output parameters
                context.OutputParameters[OUTPUT_TOTAL_AMOUNT] = totalAmount;
                context.OutputParameters[OUTPUT_TAX_AMOUNT] = taxAmount;
                context.OutputParameters[OUTPUT_DISCOUNT_AMOUNT] = discountAmount;
                context.OutputParameters[OUTPUT_IS_SUCCESS] = true;
                context.OutputParameters[OUTPUT_ERROR_MESSAGE] = string.Empty;

                tracingService.Trace("Calculation complete. Total={0}", totalAmount);
            }
            catch (Exception ex)
            {
                tracingService.Trace("CalculateOrderTotalHandler: Error. {0}", ex);
                context.OutputParameters[OUTPUT_IS_SUCCESS] = false;
                context.OutputParameters[OUTPUT_ERROR_MESSAGE] = ex.Message;
                context.OutputParameters[OUTPUT_TOTAL_AMOUNT] = 0m;
                context.OutputParameters[OUTPUT_TAX_AMOUNT] = 0m;
                context.OutputParameters[OUTPUT_DISCOUNT_AMOUNT] = 0m;
            }
        }
    }
}
```

### Paso 6: Invocar desde TypeScript / JavaScript

```typescript
// Ejemplo de invocación desde una Web Resource o PCF
async function calculateOrderTotal(
    opportunityId: string,
    includeTax: boolean,
    discountPercentage: number
): Promise<{ totalAmount: number; isSuccess: boolean; errorMessage: string }> {
    
    const requestBody = {
        IncludeTax: includeTax,
        DiscountPercentage: discountPercentage
    };

    const response = await Xrm.WebApi.online.execute({
        getMetadata: () => ({
            boundParameter: "entity",
            parameterTypes: {
                entity: {
                    typeName: "mscrm.opportunity",
                    structuralProperty: 5 // EntityType
                },
                IncludeTax: { typeName: "Edm.Boolean", structuralProperty: 1 },
                DiscountPercentage: { typeName: "Edm.Decimal", structuralProperty: 1 }
            },
            operationType: 0, // Action
            operationName: "src_CalculateOrderTotal"
        }),
        entity: { opportunityid: opportunityId, "@odata.type": "Microsoft.Dynamics.CRM.opportunity" },
        ...requestBody
    });

    const result = await response.json();
    return {
        totalAmount: result.TotalAmount,
        isSuccess: result.IsSuccess,
        errorMessage: result.ErrorMessage
    };
}
```

### Paso 7: Registrar el Handler

```powershell
# Build y push del plugin handler
dotnet build -c Release
pac plugin push --pluginFile ./bin/Release/net462/Fran.Sales.dll

# Asociar el handler a la Custom API (en Plugin Registration Tool o portal)
# Plugin type: CalculateOrderTotalHandler
# Step: src_CalculateOrderTotal
# Execution order: 1
```

### Paso 8: Resumen Final

- Custom API definida en Dataverse con PAC CLI
- Plugin handler generado y registrado
- Ejemplo de invocación TypeScript listo
- Próximos pasos: tests (`/code-review`), documentación OpenAPI (`/doc-generator`), pipeline ALM (`/alm-pipeline`)
