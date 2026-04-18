# Common Dataverse Development Patterns

> Proven patterns for Dynamics 365 / Power Platform development.
> All C# examples target **.NET Framework 4.7.1** (IOrganizationService SDK).
> All JS examples use the **formContext** API — never `Xrm.Page`.

---

## 1. C# Plugin Patterns

### 1.1 Pre-Validation Plugin (Stage 10)

Use for: input validation, permission checks, duplicate detection.
Runs **before** the database transaction starts — throwing here is cheap.

```csharp
using System;
using Microsoft.Xrm.Sdk;

namespace Contoso.Sales.Plugins
{
    public class AccountValidatePrePlugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracer  = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity target)
            {
                tracer.Trace("AccountValidatePrePlugin: Validating account.");

                var name = target.GetAttributeValue<string>("name");
                if (string.IsNullOrWhiteSpace(name))
                {
                    throw new InvalidPluginExecutionException(
                        "Account name is required.");
                }

                var revenue = target.GetAttributeValue<Money>("revenue");
                if (revenue != null && revenue.Value < 0)
                {
                    throw new InvalidPluginExecutionException(
                        "Revenue cannot be negative.");
                }
            }
        }
    }
}
```

### 1.2 Pre-Operation Plugin (Stage 20)

Use for: data transformation, default values, field calculation, cross-entity validation.
Runs **inside** the database transaction, before the core operation.

```csharp
using System;
using Microsoft.Xrm.Sdk;

namespace Contoso.Sales.Plugins
{
    public class InvoiceLineCalculatePrePlugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracer  = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity target)
            {
                tracer.Trace("InvoiceLineCalculatePrePlugin: Calculating line total.");

                var quantity  = target.GetAttributeValue<int?>("quantity") ?? 0;
                var unitPrice = target.GetAttributeValue<Money>("priceperunit");

                if (unitPrice != null && quantity > 0)
                {
                    var lineTotal = quantity * unitPrice.Value;
                    target["extendedamount"] = new Money(lineTotal);
                    tracer.Trace($"Calculated line total: {lineTotal}");
                }
            }
        }
    }
}
```

### 1.3 Post-Operation Sync Plugin (Stage 40, Mode 0)

Use for: side effects that must complete before the response returns (create child records, send immediate notifications).

```csharp
using System;
using Microsoft.Xrm.Sdk;

namespace Contoso.Sales.Plugins
{
    public class OpportunityCreatePostPlugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = factory.CreateOrganizationService(context.UserId);
            var tracer  = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity target)
            {
                tracer.Trace("OpportunityCreatePostPlugin: Creating default task.");

                var task = new Entity("task")
                {
                    ["subject"]            = "Follow up on new opportunity",
                    ["regardingobjectid"]  = new EntityReference("opportunity", target.Id),
                    ["scheduledend"]       = DateTime.UtcNow.AddDays(7)
                };

                service.Create(task);
                tracer.Trace("Default task created.");
            }
        }
    }
}
```

### 1.4 Post-Operation Async Plugin (Stage 40, Mode 1)

Use for: non-critical side effects — audit logging, external system sync, heavy processing.
Runs outside the main transaction in an async service queue.

```csharp
using System;
using Microsoft.Xrm.Sdk;

namespace Contoso.Sales.Plugins
{
    public class CaseEscalatePostAsyncPlugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = factory.CreateOrganizationService(context.UserId);
            var tracer  = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            if (context.PostEntityImages.Contains("PostImage"))
            {
                var postImage = context.PostEntityImages["PostImage"];
                var priority  = postImage.GetAttributeValue<OptionSetValue>("prioritycode");

                // Escalate if priority is High (1)
                if (priority != null && priority.Value == 1)
                {
                    tracer.Trace("CaseEscalatePostAsyncPlugin: High priority — escalating.");

                    var update = new Entity("incident", postImage.Id)
                    {
                        ["followupby"] = DateTime.UtcNow.AddHours(4)
                    };
                    service.Update(update);
                }
            }
        }
    }
}
```

### 1.5 Pipeline Shared Variables

Pass data between plugin stages registered on the same message.

```csharp
// --- Stage 20 (Pre-Operation) — set shared variable ---
context.SharedVariables["OriginalAmount"] = currentAmount;

// --- Stage 40 (Post-Operation) — read shared variable ---
if (context.ParentContext != null &&
    context.ParentContext.SharedVariables.Contains("OriginalAmount"))
{
    var originalAmount = (decimal)context.ParentContext.SharedVariables["OriginalAmount"];
    tracer.Trace($"Original amount was: {originalAmount}");
}
```

### 1.6 Pre / Post Entity Images

Read the entity state **before** and **after** the core operation.
Register images in the Plugin Registration Tool.

```csharp
// Pre-Image — state BEFORE the operation (available in Update/Delete)
if (context.PreEntityImages.Contains("PreImage"))
{
    var preImage = context.PreEntityImages["PreImage"];
    var oldStatus = preImage.GetAttributeValue<OptionSetValue>("statuscode");
    tracer.Trace($"Previous status: {oldStatus?.Value}");
}

// Post-Image — state AFTER the operation (available in Post-Operation)
if (context.PostEntityImages.Contains("PostImage"))
{
    var postImage = context.PostEntityImages["PostImage"];
    var newStatus = postImage.GetAttributeValue<OptionSetValue>("statuscode");
    tracer.Trace($"New status: {newStatus?.Value}");
}
```

### 1.7 Secure / Unsecure Configuration

Store configuration data that varies per plugin step registration.

```csharp
public class ConfigurablePlugin : IPlugin
{
    private readonly string _unsecureConfig;
    private readonly string _secureConfig;

    // Constructor receives configuration strings from plugin step registration
    public ConfigurablePlugin(string unsecureConfig, string secureConfig)
    {
        _unsecureConfig = unsecureConfig; // Visible to all users
        _secureConfig   = secureConfig;   // Visible only to System Admins
    }

    public void Execute(IServiceProvider serviceProvider)
    {
        var tracer = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

        // Parse configuration (commonly JSON or XML)
        tracer.Trace($"Unsecure config: {_unsecureConfig}");
        // NEVER log secure config in production
    }
}
```

---

## 2. TypeScript / JavaScript Form Patterns

### 2.1 Form OnLoad

```javascript
var Contoso = Contoso || {};
Contoso.Account = Contoso.Account || {};

/**
 * Account form OnLoad handler.
 * @param {Xrm.Events.EventContext} executionContext
 */
Contoso.Account.onLoad = function (executionContext) {
    "use strict";
    var formContext = executionContext.getFormContext();
    var formType   = formContext.ui.getFormType();

    // 1 = Create, 2 = Update, 3 = Read Only, 4 = Disabled
    if (formType === 1) {
        formContext.getAttribute("creditlimit").setValue(10000);
    }

    // Set fields required based on category
    var category = formContext.getAttribute("accountcategorycode").getValue();
    if (category === 1) { // Preferred Customer
        formContext.getAttribute("emailaddress1")
            .setRequiredLevel("required");
    }

    // Register OnChange handlers
    formContext.getAttribute("industrycode")
        .addOnChange(Contoso.Account.onChangeIndustry);
};

// Module exports for testing
if (typeof module !== "undefined") {
    module.exports = Contoso.Account;
}
```

### 2.2 Field OnChange

```javascript
/**
 * Handle industry code change — set default SIC code.
 * @param {Xrm.Events.EventContext} executionContext
 */
Contoso.Account.onChangeIndustry = function (executionContext) {
    "use strict";
    var formContext = executionContext.getFormContext();
    var industry    = formContext.getAttribute("industrycode").getValue();

    // Map industry to default SIC code
    var sicMap = {
        1: "0100",  // Agriculture
        2: "1000",  // Mining
        3: "2000"   // Manufacturing
    };

    var sicCode = sicMap[industry] || null;
    formContext.getAttribute("sic").setValue(sicCode);
};
```

### 2.3 Form OnSave

```javascript
/**
 * Account form OnSave handler — validate before save.
 * @param {Xrm.Events.EventContext} executionContext
 */
Contoso.Account.onSave = function (executionContext) {
    "use strict";
    var formContext = executionContext.getFormContext();
    var saveEvent   = executionContext.getEventArgs();

    var phone = formContext.getAttribute("telephone1").getValue();
    var email = formContext.getAttribute("emailaddress1").getValue();

    if (!phone && !email) {
        saveEvent.preventDefault();
        formContext.ui.setFormNotification(
            "Please provide at least a phone number or email address.",
            "ERROR",
            "contact_validation"
        );
    } else {
        formContext.ui.clearFormNotification("contact_validation");
    }
};
```

### 2.4 Tab / Section Visibility

```javascript
/**
 * Toggle tab visibility based on account type.
 * @param {Xrm.FormContext} formContext
 */
Contoso.Account.toggleFinancialTab = function (formContext) {
    "use strict";
    var accountType = formContext.getAttribute("customertypecode").getValue();
    var financialTab = formContext.ui.tabs.get("tab_financial");

    if (financialTab) {
        // Show financial tab only for Customers (value 3)
        financialTab.setVisible(accountType === 3);
    }

    // Toggle a section within a tab
    var creditSection = formContext.ui.tabs.get("tab_general")
        .sections.get("section_credit");
    if (creditSection) {
        creditSection.setVisible(accountType === 3);
    }
};
```

### 2.5 Ribbon Command — Enable Rule

```javascript
/**
 * Enable rule for custom ribbon button.
 * @param {Xrm.FormContext} primaryControl - passed via CrmParameter
 * @returns {boolean}
 */
Contoso.Account.enableApproveButton = function (primaryControl) {
    "use strict";
    var formContext = primaryControl;
    var statusCode = formContext.getAttribute("statuscode").getValue();

    // Enable only when status is "Pending Approval" (e.g., 100000001)
    return statusCode === 100000001;
};
```

### 2.6 Web API from Form Scripts

```javascript
/**
 * Retrieve the primary contact's full name using Web API.
 * @param {Xrm.FormContext} formContext
 */
Contoso.Account.loadPrimaryContact = function (formContext) {
    "use strict";
    var contactRef = formContext.getAttribute("primarycontactid").getValue();
    if (!contactRef || contactRef.length === 0) return;

    var contactId = contactRef[0].id.replace(/[{}]/g, "");

    Xrm.WebApi.retrieveRecord("contact", contactId, "?$select=fullname,emailaddress1")
        .then(function (result) {
            formContext.ui.setFormNotification(
                "Primary contact: " + result.fullname,
                "INFO",
                "primary_contact_info"
            );
        })
        .catch(function (error) {
            console.error("Error retrieving contact: " + error.message);
        });
};

/**
 * Retrieve multiple records example.
 * @param {Xrm.FormContext} formContext
 */
Contoso.Account.loadActiveOpportunities = function (formContext) {
    "use strict";
    var accountId = formContext.data.entity.getId().replace(/[{}]/g, "");

    Xrm.WebApi.retrieveMultipleRecords(
        "opportunity",
        "?$select=name,estimatedvalue" +
        "&$filter=_parentaccountid_value eq " + accountId +
        " and statecode eq 0" +
        "&$orderby=estimatedvalue desc" +
        "&$top=10"
    ).then(function (result) {
        console.log("Open opportunities: " + result.entities.length);
    }).catch(function (error) {
        console.error("Error: " + error.message);
    });
};
```

---

## 3. OData Query Patterns

### 3.1 Basic Query

```http
GET /api/data/v9.2/accounts?$select=name,revenue&$filter=statecode eq 0
```

### 3.2 Filtering

```http
# Equals
$filter=name eq 'Contoso'

# Contains
$filter=contains(name,'Contoso')

# Greater than date
$filter=createdon gt 2024-01-01T00:00:00Z

# Multiple conditions
$filter=statecode eq 0 and revenue gt 1000000

# In list (alternative to OR chain)
$filter=Microsoft.Dynamics.CRM.In(PropertyName='industrycode',PropertyValues=[1,2,3])
```

### 3.3 Expand (Related Records)

```http
# Single related record
GET /api/data/v9.2/accounts?$select=name&$expand=primarycontactid($select=fullname,emailaddress1)

# Collection (1:N related records)
GET /api/data/v9.2/accounts(00000000-0000-0000-0000-000000000001)?$select=name&$expand=Account_Tasks($select=subject,scheduledend;$top=5)
```

### 3.4 Aggregate

```http
GET /api/data/v9.2/opportunities?$apply=groupby((parentaccountid),aggregate(estimatedvalue with sum as total_value))
```

### 3.5 Batch Requests

```http
POST /api/data/v9.2/$batch
Content-Type: multipart/mixed; boundary=batch_123

--batch_123
Content-Type: multipart/mixed; boundary=changeset_456

--changeset_456
Content-Type: application/http
Content-Transfer-Encoding: binary

POST /api/data/v9.2/accounts HTTP/1.1
Content-Type: application/json

{"name":"Account 1"}

--changeset_456
Content-Type: application/http
Content-Transfer-Encoding: binary

POST /api/data/v9.2/accounts HTTP/1.1
Content-Type: application/json

{"name":"Account 2"}

--changeset_456--
--batch_123--
```

### 3.6 FetchXML via OData

```http
GET /api/data/v9.2/accounts?fetchXml=<fetch top="10"><entity name="account"><attribute name="name"/><attribute name="revenue"/><filter><condition attribute="statecode" operator="eq" value="0"/></filter><order attribute="revenue" descending="true"/></entity></fetch>
```

### 3.7 Paging

```
# First page — returns @odata.nextLink if more records exist
GET /api/data/v9.2/accounts?$select=name&$top=5000

# Next page — use the full @odata.nextLink URL from previous response
GET {value of @odata.nextLink}
```

> **Maximum records per page**: 5000. Always check for `@odata.nextLink` to detect additional pages.

---

## 4. QueryExpression / FetchXML Patterns (C# SDK)

### 4.1 QueryExpression

```csharp
var query = new QueryExpression("account")
{
    ColumnSet = new ColumnSet("name", "revenue", "primarycontactid"),
    Criteria = new FilterExpression(LogicalOperator.And)
    {
        Conditions =
        {
            new ConditionExpression("statecode", ConditionOperator.Equal, 0),
            new ConditionExpression("revenue", ConditionOperator.GreaterThan, 100000m)
        }
    },
    Orders = { new OrderExpression("revenue", OrderType.Descending) },
    TopCount = 50
};

// Add a Link Entity (JOIN)
var contactLink = query.AddLink("contact", "primarycontactid", "contactid", JoinOperator.LeftOuter);
contactLink.Columns = new ColumnSet("fullname", "emailaddress1");
contactLink.EntityAlias = "pc";

var results = service.RetrieveMultiple(query);
foreach (var account in results.Entities)
{
    var name         = account.GetAttributeValue<string>("name");
    var contactName  = account.GetAttributeValue<AliasedValue>("pc.fullname")?.Value as string;
    tracer.Trace($"{name} — Contact: {contactName}");
}
```

### 4.2 FetchXML with Aggregates

```csharp
var fetchXml = @"
<fetch aggregate='true'>
  <entity name='opportunity'>
    <attribute name='estimatedvalue' alias='total_value' aggregate='sum' />
    <attribute name='parentaccountid' alias='account' groupby='true' />
    <filter>
      <condition attribute='statecode' operator='eq' value='0' />
    </filter>
  </entity>
</fetch>";

var result = service.RetrieveMultiple(new FetchExpression(fetchXml));
foreach (var record in result.Entities)
{
    var account = record.GetAttributeValue<AliasedValue>("account");
    var total   = record.GetAttributeValue<AliasedValue>("total_value");
    tracer.Trace($"Account: {account?.Value} — Total: {total?.Value}");
}
```

### 4.3 Paging with PagingCookie

```csharp
var query = new QueryExpression("account")
{
    ColumnSet = new ColumnSet("name"),
    PageInfo  = new PagingInfo { PageNumber = 1, Count = 5000, ReturnTotalRecordCount = true }
};

EntityCollection results;
do
{
    results = service.RetrieveMultiple(query);
    foreach (var entity in results.Entities)
    {
        // Process each record
    }

    query.PageInfo.PageNumber++;
    query.PageInfo.PagingCookie = results.PagingCookie;
}
while (results.MoreRecords);
```

---

## 5. Error Handling Patterns

### 5.1 C# Plugins

```csharp
public void Execute(IServiceProvider serviceProvider)
{
    var tracer = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

    try
    {
        tracer.Trace("Plugin execution started.");
        // ... business logic ...
    }
    catch (InvalidPluginExecutionException)
    {
        // Re-throw business exceptions — they show the message to the user
        throw;
    }
    catch (Exception ex)
    {
        tracer.Trace($"Unexpected error: {ex}");
        throw new InvalidPluginExecutionException(
            "An unexpected error occurred. Please contact your administrator.", ex);
    }
}
```

### 5.2 JavaScript

```javascript
Contoso.Account.riskyOperation = function (executionContext) {
    "use strict";
    var formContext = executionContext.getFormContext();

    try {
        // ... business logic ...
    } catch (error) {
        // Option A — form notification (non-blocking)
        formContext.ui.setFormNotification(
            "An error occurred: " + error.message,
            "ERROR",
            "operation_error"
        );

        // Option B — alert dialog (blocking)
        Xrm.Navigation.openAlertDialog({
            text: "Operation failed: " + error.message,
            title: "Error"
        });
    }
};
```

### 5.3 Power Automate — Scope-Based Try/Catch

```
Flow structure:
├── Scope: Try
│   ├── Action 1
│   ├── Action 2
│   └── Action 3
├── Scope: Catch  (Run After: Try → has failed, has timed out)
│   ├── Log error details
│   └── Send notification
└── Scope: Finally  (Run After: Try → succeeded, Catch → succeeded)
    └── Cleanup actions
```

> Configure **Run After** on the Catch scope to run when Try `has failed` or `has timed out`.

---

## 6. Batch Operations

### 6.1 ExecuteMultipleRequest

Process records in batches. Continues on error by default.

```csharp
var requests = new ExecuteMultipleRequest
{
    Requests = new OrganizationRequestCollection(),
    Settings = new ExecuteMultipleSettings
    {
        ContinueOnError = true,
        ReturnResponses  = true
    }
};

var records = GetRecordsToProcess(); // your collection
int batchSize = 1000;

for (int i = 0; i < records.Count; i++)
{
    requests.Requests.Add(new UpdateRequest { Target = records[i] });

    // Execute when batch is full or at the end
    if (requests.Requests.Count == batchSize || i == records.Count - 1)
    {
        var response = (ExecuteMultipleResponse)service.Execute(requests);

        if (response.IsFaulted)
        {
            foreach (var item in response.Responses)
            {
                if (item.Fault != null)
                {
                    tracer.Trace($"Error on index {item.RequestIndex}: {item.Fault.Message}");
                }
            }
        }

        requests.Requests.Clear();
    }
}
```

### 6.2 ExecuteTransactionRequest

All-or-nothing — if any request fails, the entire batch rolls back.

```csharp
var transaction = new ExecuteTransactionRequest
{
    Requests = new OrganizationRequestCollection(),
    ReturnResponses = true
};

transaction.Requests.Add(new CreateRequest { Target = record1 });
transaction.Requests.Add(new CreateRequest { Target = record2 });
transaction.Requests.Add(new CreateRequest { Target = record3 });

try
{
    var response = (ExecuteTransactionResponse)service.Execute(transaction);
    tracer.Trace($"All {response.Responses.Count} records created.");
}
catch (FaultException<OrganizationServiceFault> ex)
{
    tracer.Trace($"Transaction failed at index {ex.Detail.ErrorDetails["OperationIndex"]}: {ex.Message}");
    throw new InvalidPluginExecutionException("Batch creation failed.", ex);
}
```

---

## 7. Common Anti-Patterns

### 7.1 Retrieve Inside Loops (N+1 Query Problem)

```csharp
// ❌ BAD — one query per iteration
foreach (var id in accountIds)
{
    var account = service.Retrieve("account", id, new ColumnSet("name"));
}

// ✅ GOOD — single query with IN condition
var query = new QueryExpression("account")
{
    ColumnSet = new ColumnSet("name"),
    Criteria = new FilterExpression()
};
query.Criteria.AddCondition("accountid", ConditionOperator.In, accountIds.Cast<object>().ToArray());
var results = service.RetrieveMultiple(query);
```

### 7.2 Using Xrm.Page (Deprecated)

```javascript
// ❌ BAD — Xrm.Page is deprecated since v9.0
var name = Xrm.Page.getAttribute("name").getValue();

// ✅ GOOD — use formContext from executionContext
var formContext = executionContext.getFormContext();
var name = formContext.getAttribute("name").getValue();
```

### 7.3 Synchronous XMLHttpRequest

```javascript
// ❌ BAD — synchronous XHR blocks the UI thread
var xhr = new XMLHttpRequest();
xhr.open("GET", url, false); // false = synchronous
xhr.send();

// ✅ GOOD — use async Xrm.WebApi
Xrm.WebApi.retrieveRecord("account", id, "?$select=name")
    .then(function (result) { /* handle */ })
    .catch(function (error) { /* handle */ });
```

### 7.4 Hardcoded GUIDs

```csharp
// ❌ BAD — GUIDs differ across environments
var teamId = new Guid("A1B2C3D4-E5F6-7890-ABCD-EF1234567890");

// ✅ GOOD — query by name or use environment variables
var query = new QueryExpression("team")
{
    ColumnSet = new ColumnSet("teamid"),
    Criteria = new FilterExpression()
};
query.Criteria.AddCondition("name", ConditionOperator.Equal, "Sales Team");
var team = service.RetrieveMultiple(query).Entities.FirstOrDefault();
```

### 7.5 Thread.Sleep in Plugins

```csharp
// ❌ BAD — blocks the execution thread; may cause timeouts
Thread.Sleep(5000);

// ✅ GOOD — use async plugins or Power Automate for delays/retries
```

### 7.6 Static Variables in Plugins

```csharp
// ❌ BAD — static state is shared across ALL executions in the AppDomain
public class BadPlugin : IPlugin
{
    private static int counter = 0;  // DANGEROUS — race conditions
    public void Execute(IServiceProvider sp) { counter++; }
}

// ✅ GOOD — plugins must be stateless; use context or configuration
public class GoodPlugin : IPlugin
{
    public void Execute(IServiceProvider sp)
    {
        // All state comes from the execution context
        var context = (IPluginExecutionContext)sp.GetService(typeof(IPluginExecutionContext));
    }
}
```

### 7.7 Ignoring Plugin Depth (Infinite Loops)

```csharp
// ❌ BAD — update triggers the same plugin again, creating an infinite loop
public void Execute(IServiceProvider serviceProvider)
{
    var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
    var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
    var service = factory.CreateOrganizationService(context.UserId);

    // Missing depth check!
    var update = new Entity("account", context.PrimaryEntityId);
    update["description"] = "Updated";
    service.Update(update); // Triggers this plugin again!
}

// ✅ GOOD — guard with depth check
public void Execute(IServiceProvider serviceProvider)
{
    var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

    if (context.Depth > 1) return; // Prevent re-entrant execution

    // Safe to proceed
}
```

---

## Quick Reference — When to Use What

| Scenario | Pattern |
|---|---|
| Validate input before save | Pre-Validation Plugin (Stage 10) |
| Set default / calculated values | Pre-Operation Plugin (Stage 20) |
| Create related records after save | Post-Operation Sync Plugin (Stage 40) |
| Sync to external system | Post-Operation Async Plugin (Stage 40) |
| Show/hide form fields | JS Form OnLoad + OnChange |
| Block save on validation failure | JS Form OnSave with `preventDefault()` |
| Read related data in form | `Xrm.WebApi.retrieveRecord` |
| Bulk update records | ExecuteMultipleRequest (batches of 1000) |
| All-or-nothing batch | ExecuteTransactionRequest |
| Query with aggregates | FetchXML |
| Simple filtered query | QueryExpression or OData |
| Error handling in flows | Scope-based try/catch with Run After |
