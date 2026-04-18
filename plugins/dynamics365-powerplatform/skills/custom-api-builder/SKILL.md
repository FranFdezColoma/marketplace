---
name: custom-api-builder
description: 'Create Dataverse Custom APIs with C# plugin implementations, request/response parameter definitions, and registration metadata. Generates production-ready code targeting .NET Framework 4.7.1 with proper validation, error handling, and test coverage.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: code-generation
  stack: dynamics365-powerplatform
  framework: net471
---

# Custom API Builder

Build Dataverse Custom APIs end-to-end: registration metadata, C# plugin implementation, unit tests, and multi-platform usage examples.

---

## 1. What Is a Custom API

A Dataverse Custom API is the **recommended way** to create your own reusable API messages in Microsoft Dataverse. Custom APIs can be called from:

- **C# SDK** (`OrganizationRequest`)
- **JavaScript** (`Xrm.WebApi.online.execute`)
- **OData / HTTP** (POST to the Web API endpoint)
- **Power Automate** (the _Perform an unbound action_ or _Perform a bound action_ step)
- **Other external systems** via the Dataverse Web API

### Custom APIs vs Custom Actions

| Aspect | Custom API | Custom Action (legacy) |
|--------|-----------|----------------------|
| Status | **Recommended** for new development | Deprecated for new development |
| Implementation | C# plugin class | Workflow or C# plugin |
| Function support | Yes (`IsFunction = true` for GET-like operations) | No |
| Private support | Yes (`IsPrivate = true` hides from discovery) | No |
| Parameter types | Rich type set including `EntityCollection`, `StringArray` | Limited |
| Registration | Code-first or manual via solution | Workflow designer |

> **Rule**: Always use Custom APIs for new development. Only maintain existing Custom Actions.

---

## 2. Custom API Registration Metadata

For **every** Custom API you generate, produce a metadata block using this template:

```
Custom API:
  Unique Name: {prefix}_{ApiName}
  Display Name: {Display Name}
  Description: {What it does}
  Binding Type: Global | Entity | EntityCollection
  Bound Entity (if applicable): {logicalname}
  Is Function: false (side effects) | true (read-only)
  Is Private: false (default) | true
  Plugin Type: {Namespace}.Plugins.{ClassName}
  Allowed Custom Processing Step Type: None | Async | Sync | SyncAndAsync

Request Parameters:
  - Name: {prefix}_{ParameterName}
    Type: String | Integer | Decimal | Boolean | DateTime | Entity | EntityReference | EntityCollection | Money | OptionSetValue | StringArray | Guid | Float
    Required: true | false
    Description: {description}

Response Properties:
  - Name: {prefix}_{PropertyName}
    Type: {same types as above}
    Description: {description}
```

### Metadata Rules

1. **Unique Name** must use the publisher prefix followed by underscore: `{prefix}_{PascalCaseName}`.
2. **Binding Type**:
   - `Global` — the API is not tied to any entity (most common).
   - `Entity` — bound to a single record; the record reference is passed implicitly as `Target`.
   - `EntityCollection` — bound to a collection of an entity type.
3. **Is Function**: set to `true` only if the API **never** produces side effects (read-only queries). Functions use GET in OData; actions use POST.
4. **Is Private**: set to `true` to hide from API metadata discovery ($metadata). Useful for internal-only APIs.
5. **Allowed Custom Processing Step Type**: controls whether other plugins can register pre/post steps on your API message.
   - `None` — no external steps allowed.
   - `Async` — only async post-operation steps.
   - `Sync` — synchronous steps allowed.
   - `SyncAndAsync` — both allowed.
6. **Parameter / Property Names** must also use the publisher prefix: `{prefix}_{PascalCaseName}`.
7. Every required request parameter must be validated in the plugin code.

---

## 3. C# Plugin Implementation Template

Use the following template as the base for every Custom API plugin. Replace all `{placeholders}`.

```csharp
using System;
using Microsoft.Xrm.Sdk;

namespace {Namespace}.Plugins
{
    /// <summary>
    /// Custom API: {prefix}_{ApiName}
    /// {Description}
    /// </summary>
    public class {ApiName}Plugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var service = factory.CreateOrganizationService(context.UserId);

            tracingService.Trace("{ApiName}Plugin execution started.");

            try
            {
                // ── Extract Request Parameters ──────────────────────────
                // var param1 = (string)context.InputParameters["{prefix}_{Param1}"];

                // ── Validate ────────────────────────────────────────────
                // if (string.IsNullOrWhiteSpace(param1))
                //     throw new InvalidPluginExecutionException("Parameter '{prefix}_{Param1}' is required.");

                // ── Business Logic ──────────────────────────────────────
                // TODO: Implement

                // ── Set Response Properties ─────────────────────────────
                // context.OutputParameters["{prefix}_{Response1}"] = result;

                tracingService.Trace("{ApiName}Plugin execution completed successfully.");
            }
            catch (InvalidPluginExecutionException)
            {
                throw;
            }
            catch (Exception ex)
            {
                tracingService.Trace("Error in {ApiName}Plugin: {0}", ex.ToString());
                throw new InvalidPluginExecutionException(
                    $"An error occurred in {ApiName}. Please contact your administrator.", ex);
            }
        }
    }
}
```

### Implementation Rules

1. **Always** obtain `IPluginExecutionContext`, `IOrganizationServiceFactory`, and `ITracingService` from the service provider.
2. **Always** wrap business logic in a try/catch:
   - Re-throw `InvalidPluginExecutionException` as-is (these carry user-facing messages).
   - Catch generic `Exception`, trace the full details, then wrap in a new `InvalidPluginExecutionException` with a user-friendly message.
3. **Trace** at entry, at key steps, and at exit.
4. **Validate** every required input parameter before processing.
5. **Do not** hardcode entity names, field names, or GUIDs — use constants or configuration.
6. **Target .NET Framework 4.7.1** — do not use C# features beyond what 4.7.1 supports.

---

## 4. Usage Examples

For **every** Custom API, generate these four usage examples.

### 4.1 C# SDK Call

```csharp
var request = new OrganizationRequest("{prefix}_{ApiName}");
request["{prefix}_{Param1}"] = "value1";
request["{prefix}_{Param2}"] = 42;

var response = service.Execute(request);

var result = (string)response["{prefix}_{ResponseProp1}"];
```

### 4.2 JavaScript — Xrm.WebApi.online.execute

```javascript
var request = {
    // Request parameters
    {prefix}_{Param1}: "value1",
    {prefix}_{Param2}: 42,

    getMetadata: function () {
        return {
            boundParameter: null,          // null for Global, "entity" for Entity-bound
            operationType: 0,              // 0 = Action, 1 = Function
            operationName: "{prefix}_{ApiName}",
            parameterTypes: {
                "{prefix}_{Param1}": {
                    typeName: "Edm.String",
                    structuralProperty: 1  // 1 = PrimitiveType
                },
                "{prefix}_{Param2}": {
                    typeName: "Edm.Int32",
                    structuralProperty: 1
                }
            }
        };
    }
};

Xrm.WebApi.online.execute(request).then(
    function (response) {
        if (response.ok) {
            return response.json();
        }
    }
).then(function (result) {
    var value = result["{prefix}_{ResponseProp1}"];
    console.log(value);
}).catch(function (error) {
    console.error(error.message);
});
```

### 4.3 OData HTTP Request

**Global (unbound) action:**

```http
POST [Organization URI]/api/data/v9.2/{prefix}_{ApiName}
Content-Type: application/json
Authorization: Bearer {token}

{
    "{prefix}_{Param1}": "value1",
    "{prefix}_{Param2}": 42
}
```

**Entity-bound action:**

```http
POST [Organization URI]/api/data/v9.2/{entitysetname}({recordid})/Microsoft.Dynamics.CRM.{prefix}_{ApiName}
Content-Type: application/json
Authorization: Bearer {token}

{
    "{prefix}_{Param1}": "value1"
}
```

### 4.4 Power Automate

- **Unbound action**: Use the _Perform an unbound action_ step from the Dataverse connector.
  - Action Name: `{prefix}_{ApiName}`
  - Fill in each request parameter.
- **Bound action**: Use the _Perform a bound action_ step from the Dataverse connector.
  - Table name: select the bound entity.
  - Action Name: `{prefix}_{ApiName}`
  - Row ID: the GUID of the target record.
  - Fill in remaining parameters.

---

## 5. Companion Test Generation

Generate an MSTest + Moq test class for every Custom API plugin. Target packages:

- **MSTest.TestFramework** (2.2.x+)
- **MSTest.TestAdapter** (2.2.x+)
- **Moq** (4.18.x+)
- **Microsoft.CrmSdk.CoreAssemblies** (9.0.x+)

### Test Template

```csharp
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;

namespace {Namespace}.Plugins.Tests
{
    [TestClass]
    public class {ApiName}PluginTests
    {
        private Mock<IServiceProvider> _serviceProvider;
        private Mock<IPluginExecutionContext> _context;
        private Mock<IOrganizationServiceFactory> _factory;
        private Mock<IOrganizationService> _service;
        private Mock<ITracingService> _tracingService;
        private ParameterCollection _inputParameters;
        private ParameterCollection _outputParameters;

        [TestInitialize]
        public void Setup()
        {
            _serviceProvider = new Mock<IServiceProvider>();
            _context = new Mock<IPluginExecutionContext>();
            _factory = new Mock<IOrganizationServiceFactory>();
            _service = new Mock<IOrganizationService>();
            _tracingService = new Mock<ITracingService>();

            _inputParameters = new ParameterCollection();
            _outputParameters = new ParameterCollection();

            _context.Setup(c => c.InputParameters).Returns(_inputParameters);
            _context.Setup(c => c.OutputParameters).Returns(_outputParameters);
            _context.Setup(c => c.UserId).Returns(Guid.NewGuid());

            _factory.Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                    .Returns(_service.Object);

            _serviceProvider.Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
                            .Returns(_context.Object);
            _serviceProvider.Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
                            .Returns(_factory.Object);
            _serviceProvider.Setup(sp => sp.GetService(typeof(ITracingService)))
                            .Returns(_tracingService.Object);
        }

        [TestMethod]
        public void Execute_ValidParameters_Succeeds()
        {
            // Arrange
            // _inputParameters["{prefix}_{Param1}"] = "valid_value";

            var plugin = new {ApiName}Plugin();

            // Act
            plugin.Execute(_serviceProvider.Object);

            // Assert
            // Assert.IsTrue(_outputParameters.ContainsKey("{prefix}_{ResponseProp1}"));
            // var result = (string)_outputParameters["{prefix}_{ResponseProp1}"];
            // Assert.AreEqual("expected_value", result);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void Execute_MissingRequiredParameter_ThrowsException()
        {
            // Arrange — do NOT set the required parameter
            var plugin = new {ApiName}Plugin();

            // Act
            plugin.Execute(_serviceProvider.Object);

            // Assert — handled by ExpectedException
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void Execute_InvalidParameterValue_ThrowsException()
        {
            // Arrange
            // _inputParameters["{prefix}_{Param1}"] = "";  // invalid: empty

            var plugin = new {ApiName}Plugin();

            // Act
            plugin.Execute(_serviceProvider.Object);

            // Assert — handled by ExpectedException
        }

        [TestMethod]
        public void Execute_UnexpectedException_WrapsInInvalidPluginExecutionException()
        {
            // Arrange
            _factory.Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                    .Throws(new ApplicationException("Simulated failure"));

            var plugin = new {ApiName}Plugin();

            // Act & Assert
            var ex = Assert.ThrowsException<InvalidPluginExecutionException>(
                () => plugin.Execute(_serviceProvider.Object));

            Assert.IsNotNull(ex.InnerException);
            Assert.IsInstanceOfType(ex.InnerException, typeof(ApplicationException));
        }
    }
}
```

### Test Rules

1. Always include these four test categories: happy path, missing parameter, invalid parameter, exception wrapping.
2. Use `[TestInitialize]` to set up shared mocks.
3. Mock only Dataverse SDK interfaces — never instantiate real `OrganizationService`.
4. Verify tracing calls with `_tracingService.Verify(t => t.Trace(...))` when tracing behavior is critical.
5. Keep tests independent — no shared mutable state between test methods.

---

## 6. Workflow

Follow this sequence when the user requests a Custom API:

1. **Gather requirements** — ask for:
   - API name (PascalCase without prefix)
   - Description of what the API does
   - Binding type (Global, Entity, EntityCollection)
   - Bound entity logical name (if applicable)
   - Is Function? (true for read-only, false for side effects)
   - Request parameters (name, type, required, description)
   - Response properties (name, type, description)
   - Business logic summary
   - Publisher prefix (default: `{prefix}`)
   - C# namespace (default: `{Namespace}`)

2. **Generate registration metadata** — fill the metadata template from section 2.

3. **Generate C# plugin** — fill the implementation template from section 3, including:
   - Actual parameter extraction with correct types and casts.
   - Full validation for all required parameters.
   - Business logic implementation (or clear TODO with instructions).
   - All response properties set in `OutputParameters`.

4. **Generate unit tests** — fill the test template from section 5, including:
   - Concrete parameter values in Arrange sections.
   - Concrete assertions in Assert sections.
   - Additional test methods if the business logic has branching.

5. **Generate usage examples** — fill all four examples from section 4 with the actual API name, parameters, and response properties.

6. **Review checklist**:
   - [ ] Metadata unique names use publisher prefix.
   - [ ] All required parameters validated in plugin.
   - [ ] Exception handling follows the re-throw / wrap pattern.
   - [ ] Tracing at entry, key steps, and exit.
   - [ ] Tests cover happy path, missing param, invalid param, exception wrapping.
   - [ ] Usage examples cover C#, JS, OData, Power Automate.

---

## 7. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Custom API Unique Name | `{prefix}_{PascalCaseName}` | `contoso_CalculateDiscount` |
| Plugin Class Name | `{PascalCaseName}Plugin` | `CalculateDiscountPlugin` |
| Request Parameter | `{prefix}_{PascalCaseName}` | `contoso_OrderId` |
| Response Property | `{prefix}_{PascalCaseName}` | `contoso_DiscountAmount` |
| Test Class | `{PascalCaseName}PluginTests` | `CalculateDiscountPluginTests` |
| Namespace | `{Company}.{Project}.Plugins` | `Contoso.Sales.Plugins` |

- Use `{prefix}_` as a **configurable placeholder** throughout all generated artifacts. The user provides their actual publisher prefix at generation time.
- If the user does not specify a prefix, keep `{prefix}_` as-is so it is easy to find and replace later.
