---
name: custom-api-builder
description: Build Dataverse Custom APIs (Custom Actions and Functions) end-to-end. Guides through design, implementation, registration, and testing of Custom APIs for Dynamics 365 CE. Use when the user needs to create a new Custom API or modify an existing one.
---

# Custom API Builder for Dataverse

## When to Use

- **Custom API**: Reusable business operation callable from multiple clients, integration endpoint, solution-aware operation, enforce input/output contracts
- **Plugin Step instead**: Logic fires automatically on entity CRUD events, no external caller needed

---

## API Contract Definition

| Property | Values |
|----------|--------|
| Unique Name | `[prefix]_[VerbNoun]` (e.g., `contoso_CalculateDiscount`) |
| Binding Type | Global / Entity / EntityCollection |
| Is Function | true (read-only, no side effects) / false (action, has side effects) |
| Is Private | true (internal only) / false (externally callable) |

**Parameter types**: String, Integer, Boolean, DateTime, Entity, EntityReference, EntityCollection, Float, Decimal, Money, Guid, StringArray, PicklistValue

---

## Implementation

```csharp
using Microsoft.Xrm.Sdk;
using System;

namespace [Namespace].Plugins.CustomApis
{
    /// <summary>
    /// Custom API handler for [ApiName]. Implements the business logic
    /// exposed through the Dataverse Custom API contract.
    /// </summary>
    public class [ApiName]Plugin : IPlugin
    {
        /// <summary>
        /// Executes the Custom API logic: validates input parameters,
        /// runs business logic, and sets output parameters.
        /// </summary>
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = factory.CreateOrganizationService(context.UserId);

            try
            {
                tracingService.Trace("[ApiName]: Started.");

                // 1. Validate input parameters
                // 2. Execute business logic
                // 3. Set output parameters: context.OutputParameters["ResultName"] = value;
            }
            catch (InvalidPluginExecutionException) { throw; }
            catch (Exception ex)
            {
                tracingService.Trace($"[ApiName]: Error - {ex.Message}");
                throw new InvalidPluginExecutionException(
                    "An error occurred executing [ApiName]. Contact your administrator.", ex);
            }
        }
    }
}
```

### Registration

1. **Maker Portal**: Settings > Custom APIs
2. **PAC CLI**: Deploy via solution
3. **Code**: Create records in `customapi`, `customapirequestparameter`, `customapiresponseproperty` tables

---

## CLI Commands

```powershell
msbuild /p:Configuration=Release [SolutionName].sln
pac plugin push --assembly [path-to-dll]
pac solution export --name [SolutionName] --path [output-path] --managed
```

---

## Best Practices

1. Naming: publisher prefix + descriptive verb + noun
2. Design for idempotency (safe to call multiple times)
3. Validate all inputs before processing
4. Use ITracingService extensively
5. Return user-friendly errors, log technical details
6. Use `IsPrivate` for internal-only operations
7. Document the API contract

---

## Patterns

See `./reference/custom-api-patterns.md` for: CRUD orchestration, validation, integration gateway, batch operations, status transitions.
