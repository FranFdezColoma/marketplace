# Custom API Patterns for Dataverse

## Pattern 1: CRUD Orchestration

Creates a complex entity graph as a single atomic operation.

```csharp
/// <summary>
/// Custom API handler that creates an order together with its line items
/// as a single atomic operation.
/// </summary>
public class CreateOrderWithLinesPlugin : IPlugin
{
    /// <summary>
    /// Reads OrderHeader and LineItems from input parameters, creates the order,
    /// associates all line items, and returns the new order ID and line count.
    /// </summary>
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
        var service = factory.CreateOrganizationService(context.UserId);

        tracingService.Trace("CreateOrderWithLines: Started.");

        try
        {
            var orderHeader = (Entity)context.InputParameters["OrderHeader"];
            var lineItems = (EntityCollection)context.InputParameters["LineItems"];

            var orderId = service.Create(orderHeader);
            tracingService.Trace($"CreateOrderWithLines: Order created. Id={orderId}");

            foreach (var line in lineItems.Entities)
            {
                line["salesorderid"] = new EntityReference("salesorder", orderId);
                service.Create(line);
            }

            context.OutputParameters["OrderId"] = orderId.ToString();
            context.OutputParameters["LineCount"] = lineItems.Entities.Count;
            tracingService.Trace($"CreateOrderWithLines: Completed. {lineItems.Entities.Count} lines created.");
        }
        catch (InvalidPluginExecutionException) { throw; }
        catch (Exception ex)
        {
            tracingService.Trace($"CreateOrderWithLines: Error - {ex.Message}");
            throw new InvalidPluginExecutionException(
                "An error occurred creating the order with lines. Contact your administrator.", ex);
        }
    }
}
```

---

## Pattern 2: Validation API

Cross-entity or external validation that cannot be a Business Rule.

```csharp
/// <summary>
/// Custom API handler that validates a customer's available credit
/// against a requested amount and returns approval status.
/// </summary>
public class ValidateCustomerCreditPlugin : IPlugin
{
    /// <summary>
    /// Reads CustomerId and RequestedAmount from input, computes available credit,
    /// and sets IsApproved, AvailableCredit, and Reason in output parameters.
    /// </summary>
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
        var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
        var service = factory.CreateOrganizationService(context.UserId);

        tracingService.Trace("ValidateCustomerCredit: Started.");

        try
        {
            var customerId = (string)context.InputParameters["CustomerId"];
            var requestedAmount = (Money)context.InputParameters["RequestedAmount"];

            var customer = service.Retrieve("account", new Guid(customerId),
                new ColumnSet("creditlimit", "creditonhold"));

            var creditLimit = customer.GetAttributeValue<Money>("creditlimit")?.Value ?? 0;
            var isOnHold = customer.GetAttributeValue<bool>("creditonhold");
            var outstanding = CalculateOutstandingBalance(service, new Guid(customerId), tracingService);
            var available = creditLimit - outstanding;

            tracingService.Trace($"ValidateCustomerCredit: CreditLimit={creditLimit}, Outstanding={outstanding}, Available={available}");

            context.OutputParameters["IsApproved"] = !isOnHold && requestedAmount.Value <= available;
            context.OutputParameters["AvailableCredit"] = new Money(available);
            context.OutputParameters["Reason"] = isOnHold ? "Credit hold"
                : requestedAmount.Value > available ? $"Exceeds available ({available:C})" : "Approved";
        }
        catch (InvalidPluginExecutionException) { throw; }
        catch (Exception ex)
        {
            tracingService.Trace($"ValidateCustomerCredit: Error - {ex.Message}");
            throw new InvalidPluginExecutionException(
                "An error occurred validating customer credit. Contact your administrator.", ex);
        }
    }

    /// <summary>
    /// Calculates the total outstanding balance for a customer across all active invoices.
    /// </summary>
    private decimal CalculateOutstandingBalance(IOrganizationService service, Guid customerId, ITracingService tracingService)
    {
        var query = new QueryExpression("invoice")
        {
            ColumnSet = new ColumnSet("totalamount"),
            Criteria = new FilterExpression
            {
                Conditions =
                {
                    new ConditionExpression("customerid", ConditionOperator.Equal, customerId),
                    new ConditionExpression("statecode", ConditionOperator.Equal, 0)
                }
            }
        };
        var result = service.RetrieveMultiple(query).Entities
            .Sum(e => e.GetAttributeValue<Money>("totalamount")?.Value ?? 0);
        tracingService.Trace($"CalculateOutstandingBalance: {result:C}");
        return result;
    }
}
```

---

## Pattern 3: Integration Gateway

Single entry point for external systems. Design principles:
- Stable contract (versioned input/output)
- Input validation and sanitization
- Meaningful error codes
- Extensive tracing for troubleshooting

---

## Pattern 4: Batch Operations

Use `ExecuteMultipleRequest` with `ContinueOnError = true`. Return success/failure counts. Respect API limits. Consider async for >1000 records.

---

## Pattern 5: Status Transition

Enforce business rules for state changes:
- Validate current state allows transition
- Update related entities atomically
- Create audit records
- Trigger notifications
