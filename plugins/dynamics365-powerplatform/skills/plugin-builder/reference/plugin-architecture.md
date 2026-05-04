# Plugin Architecture Patterns

## Pattern 1: Service Layer

Separate business logic from infrastructure for testability and reuse.

```
Handler (IPlugin.Execute — context + dispatch)
  └── Service (business logic)
```

```csharp
/// <summary>
/// Calculates the discount amount for an order based on the customer's discount tier.
/// </summary>
public interface IDiscountCalculationService
{
    /// <summary>
    /// Returns the discount amount for the given customer and order total.
    /// </summary>
    decimal CalculateDiscount(EntityReference customerId, decimal orderAmount, IOrganizationService service);
}

/// <summary>
/// Default implementation of <see cref="IDiscountCalculationService"/> that reads the
/// customer's discount tier from Dataverse to compute the applicable discount.
/// </summary>
public class DiscountCalculationService : IDiscountCalculationService
{
    /// <summary>
    /// Retrieves the customer's discount tier and returns the discount amount.
    /// </summary>
    public decimal CalculateDiscount(EntityReference customerId, decimal orderAmount, IOrganizationService service)
    {
        var customer = service.Retrieve("account", customerId.Id, new ColumnSet("new_discounttier"));
        var tier = customer.GetAttributeValue<OptionSetValue>("new_discounttier")?.Value ?? 0;

        // Switch expression requires LangVersion 8.0+ in .csproj
        return tier switch
        {
            100000000 => orderAmount * 0.05m,  // Silver
            100000001 => orderAmount * 0.10m,  // Gold
            100000002 => orderAmount * 0.15m,  // Platinum
            _ => 0m
        };
    }
}

/// <summary>
/// Handles the Create message for the Order entity. Calculates and applies the
/// discount amount before the record is saved.
/// </summary>
public class CreateOrderHandler : IPlugin
{
    private readonly IDiscountCalculationService _discountService;

    public CreateOrderHandler() { _discountService = new DiscountCalculationService(); }
    internal CreateOrderHandler(IDiscountCalculationService svc) { _discountService = svc; }

    /// <summary>
    /// Resolves plugin services, validates execution depth, and applies the discount.
    /// </summary>
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
        var service = serviceFactory.CreateOrganizationService(context.UserId);

        if (context.Depth > 3) return;

        try
        {
            var target = (Entity)context.InputParameters["Target"];
            var customerId = target.GetAttributeValue<EntityReference>("customerid");
            var amount = target.GetAttributeValue<Money>("totalamount")?.Value ?? 0;
            target["new_discountamount"] = new Money(_discountService.CalculateDiscount(customerId, amount, service));
        }
        catch (InvalidPluginExecutionException) { throw; }
        catch (Exception ex)
        {
            tracingService.Trace($"Error: {ex}");
            throw new InvalidPluginExecutionException($"Unexpected error in {nameof(CreateOrderHandler)}.", ex);
        }
    }
}
```

---

## Pattern 2: Pre/Post Images

- **Pre-Image**: Compare old/new values, access fields not in Update target, delete scenarios
- **Post-Image**: Final state after modifications, audit logging

```csharp
// Inside Execute(), after context resolution:
var target = (Entity)context.InputParameters["Target"];

    Entity preImage = context.PreEntityImages.Contains("PreImage")
        ? context.PreEntityImages["PreImage"] : null;

    var oldStatus = preImage?.GetAttributeValue<OptionSetValue>("statuscode")?.Value;
    var newStatus = target.Contains("statuscode")
        ? target.GetAttributeValue<OptionSetValue>("statuscode")?.Value
        : oldStatus;

    if (oldStatus != newStatus)
    {
        tracingService.Trace($"Status changed: {oldStatus} → {newStatus}");
        // Handle transition
    }
}
```

---

## Pattern 3: Shared Variables

Pass data between plugins in the same pipeline execution.

```csharp
// Set in PreValidation
context.SharedVariables["IsVIPCustomer"] = true;

// Read in PostOperation (same pipeline)
if (context.SharedVariables.Contains("IsVIPCustomer"))
    var isVIP = (bool)context.SharedVariables["IsVIPCustomer"];

// From parent context (child pipelines)
if (context.ParentContext?.SharedVariables.Contains("IsVIPCustomer") == true)
    var isVIP = (bool)context.ParentContext.SharedVariables["IsVIPCustomer"];
```

---

## Pattern 4: Depth Guard

The standard depth check (`context.Depth > 3`) is inline in every `Execute()`. For shared-variable deduplication across the same pipeline:

```csharp
const string executionKey = "MyPlugin_Executed";
if (context.SharedVariables.Contains(executionKey)) return;
context.SharedVariables[executionKey] = true;
```

---

## Stage Decision Matrix

| Scenario | Stage | Mode |
|----------|-------|------|
| Validate input | PreValidation | Sync |
| Auto-populate fields | PreOperation | Sync |
| Create related records | PostOperation | Sync |
| Send notification | PostOperation | Async |
| External API call | PostOperation | Async |
| Prevent deletion | PreValidation | Sync |
| Cascade updates | PostOperation | Sync |
| Audit logging | PostOperation | Async |
