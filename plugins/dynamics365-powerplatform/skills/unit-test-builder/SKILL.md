---
name: unit-test-builder
description: 'Generate comprehensive unit tests for Dynamics 365 and Power Platform code. For C# uses MSTest + Moq (Dataverse plugin pattern). For JavaScript/TypeScript uses Vitest + xrm-mock (Form Scripts and Web Resources). Covers Arrange/Act/Assert, service mocks, happy paths, and error cases.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: testing
  stack: dynamics365-powerplatform
---

# Unit Test Builder — Dynamics 365 & Power Platform

Generate comprehensive, ready-to-run unit tests for Dynamics 365 and Power Platform code.
This skill supports two stacks:

- **C# Plugins** — MSTest + Moq (Dataverse plugin pattern)
- **JavaScript/TypeScript Form Scripts** — Vitest + xrm-mock

---

## 1. C# Plugin Testing (.NET Framework 4.7.1)

### 1.1 Test Project Setup

| Item | Value |
|------|-------|
| Target Framework | .NET Framework 4.7.1 |
| Test Framework | MSTest (`MSTest.TestFramework`, `MSTest.TestAdapter`) |
| Mocking Library | Moq |
| CRM SDK | `Microsoft.CrmSdk.CoreAssemblies` |
| Project Naming | `{PluginProject}.Tests` |

### 1.2 Standard Mock Setup

ALWAYS generate this base class for every C# plugin test file:

```csharp
[TestClass]
public class {PluginName}Tests
{
    private Mock<IOrganizationService> _mockService;
    private Mock<ITracingService> _mockTracing;
    private Mock<IPluginExecutionContext> _mockContext;
    private Mock<IServiceProvider> _mockServiceProvider;
    private Mock<IOrganizationServiceFactory> _mockFactory;

    [TestInitialize]
    public void Setup()
    {
        _mockService = new Mock<IOrganizationService>();
        _mockTracing = new Mock<ITracingService>();
        _mockContext = new Mock<IPluginExecutionContext>();
        _mockServiceProvider = new Mock<IServiceProvider>();
        _mockFactory = new Mock<IOrganizationServiceFactory>();

        _mockServiceProvider
            .Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
            .Returns(_mockContext.Object);
        _mockServiceProvider
            .Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
            .Returns(_mockFactory.Object);
        _mockServiceProvider
            .Setup(sp => sp.GetService(typeof(ITracingService)))
            .Returns(_mockTracing.Object);
        _mockFactory
            .Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
            .Returns(_mockService.Object);
    }
}
```

### 1.3 Test Naming Convention

Use the pattern: `MethodName_StateUnderTest_ExpectedBehavior`

Examples:

- `Execute_ValidAccount_SetsStatusToActive`
- `Execute_NullTarget_ReturnsWithoutProcessing`
- `Execute_InvalidData_ThrowsInvalidPluginExecutionException`

### 1.4 Standard Test Categories

ALWAYS generate tests for each of these categories:

1. **Happy path** — valid input produces expected output.
2. **Missing/null Target entity** — plugin receives no Target in InputParameters.
3. **Invalid/missing required fields** — required attributes are absent or have wrong types.
4. **Exception handling** — verify `InvalidPluginExecutionException` is thrown with the correct message.
5. **Service call verification** — verify expected Dataverse operations (`Create`, `Update`, `Retrieve`, `RetrieveMultiple`) were called with correct parameters.
6. **Pre/Post image tests** — if the plugin uses PreEntityImages or PostEntityImages, test with present and missing images.

### 1.5 Mocking Patterns

#### InputParameters with Target entity

```csharp
var target = new Entity("account", Guid.NewGuid());
target["name"] = "Contoso";
var inputParams = new ParameterCollection { { "Target", target } };
_mockContext.Setup(c => c.InputParameters).Returns(inputParams);
```

#### PreEntityImages / PostEntityImages

```csharp
var preImage = new Entity("account");
preImage["name"] = "Old Name";
var preImages = new EntityImageCollection { { "PreImage", preImage } };
_mockContext.Setup(c => c.PreEntityImages).Returns(preImages);
```

#### Service.Retrieve and RetrieveMultiple

```csharp
_mockService
    .Setup(s => s.Retrieve("account", It.IsAny<Guid>(), It.IsAny<ColumnSet>()))
    .Returns(new Entity("account") { ["name"] = "Contoso" });

var collection = new EntityCollection(new List<Entity> { resultEntity });
_mockService
    .Setup(s => s.RetrieveMultiple(It.IsAny<QueryExpression>()))
    .Returns(collection);
```

#### Specific argument matching

```csharp
_mockService.Setup(s => s.Update(It.Is<Entity>(e =>
    e.LogicalName == "account" &&
    e.GetAttributeValue<string>("name") == "Contoso"
)));
```

#### Capturing arguments with Callback

```csharp
Entity captured = null;
_mockService
    .Setup(s => s.Create(It.IsAny<Entity>()))
    .Callback<Entity>(e => captured = e)
    .Returns(Guid.NewGuid());
```

#### Call verification with Verifiable / Verify

```csharp
_mockService
    .Setup(s => s.Update(It.IsAny<Entity>()))
    .Verifiable();

// Act
plugin.Execute(_mockServiceProvider.Object);

// Assert
_mockService.Verify();
_mockService.Verify(s => s.Update(It.IsAny<Entity>()), Times.Once);
```

---

## 2. JavaScript / TypeScript Form Script Testing (Vitest + xrm-mock)

### 2.1 Test Project Setup

| Item | Value |
|------|-------|
| Test Framework | Vitest |
| Mocking Library | xrm-mock |
| Environment | jsdom |

Vitest configuration file:

```javascript
// vitest.config.js
import { defineConfig } from "vitest/config";
export default defineConfig({
    test: {
        globals: true,
        environment: "jsdom",
    },
});
```

### 2.2 CRITICAL PREREQUISITE — Module Exports

The source JavaScript file **MUST** have the module exports pattern at the end.
If it does not exist, **ADD IT FIRST** before generating tests.

```javascript
// ── Exports (for unit testing) ────────────────────────────────────────
if (typeof module !== "undefined" && module.exports) {
    module.exports = { onLoad, onChange, onSave, functionName1 };
}
```

### 2.3 Standard Test Structure

```javascript
import { describe, it, expect, beforeEach, vi } from "vitest";
import { XrmMockGenerator } from "xrm-mock";

const { onLoad, onChange } = require("../src/{FileName}");

describe("{Entity}.{Event}", () => {
    beforeEach(() => {
        XrmMockGenerator.initialise();
    });

    describe("onLoad", () => {
        it("should_DoExpectedThing_WhenConditionIsMet", () => {
            // Arrange
            XrmMockGenerator.Attribute.createString("name", "Test");
            XrmMockGenerator.Attribute.createOptionSet("statuscode", 1);
            const formContext = XrmMockGenerator.getFormContext();
            const executionContext = {
                getFormContext: () => formContext,
                getEventArgs: () => XrmMockGenerator.getEventArgs(),
            };

            // Act
            onLoad(executionContext);

            // Assert
            expect(formContext.getAttribute("name").getValue()).toBe("Expected");
        });
    });
});
```

### 2.4 xrm-mock Attribute Types

Use the correct factory method for each attribute type:

| CRM Type | Factory Method |
|----------|---------------|
| Single Line of Text | `XrmMockGenerator.Attribute.createString("name", "value")` |
| Whole Number | `XrmMockGenerator.Attribute.createNumber("age", 25)` |
| Option Set | `XrmMockGenerator.Attribute.createOptionSet("status", 1)` |
| Two Options | `XrmMockGenerator.Attribute.createBoolean("active", true)` |
| Date and Time | `XrmMockGenerator.Attribute.createDate("birthdate", new Date())` |
| Lookup | `XrmMockGenerator.Attribute.createLookup("parentid", { id: "guid", name: "name", entityType: "account" })` |

### 2.5 Standard Test Categories for Form Scripts

ALWAYS generate tests for each of these categories:

1. **Form load (onLoad)** — test with different form states (create vs. update, different statuses).
2. **Field change (onChange)** — test with different field values (null, empty, valid, boundary).
3. **Form save validation (onSave)** — verify save is prevented on validation failure using `executionContext.getEventArgs().preventDefault()`.
4. **Visibility/enablement logic** — verify fields are shown/hidden or enabled/disabled based on conditions.
5. **Tab/section visibility** — verify tab and section show/hide logic.
6. **Notification display/clearing** — verify form or field notifications are set and cleared correctly.

---

## 3. General Testing Principles

- **Arrange / Act / Assert** — follow this pattern in EVERY test.
- **One assertion per test** (preferred), or a small set of closely related assertions.
- **Test behavior, not implementation** — focus on what the code does, not how it does it.
- **Independent tests** — no shared mutable state between tests; each test sets up its own context.
- **Descriptive test names** — the name should explain the scenario without reading the code.
- **Minimum 80% code coverage** for business logic.

---

## 4. Workflow

When the user requests unit tests:

1. **Receive source code** — the user provides a plugin class or form script file.
2. **Analyze the code** — identify all testable behaviors, branches, and edge cases.
3. **Check prerequisites**:
   - For C#: verify the test project exists or provide setup instructions.
   - For JS: verify the source file has the module exports block. If missing, **add it first**.
4. **Generate the test file** with complete mock setup and all standard test categories.
5. **Include**:
   - Happy path tests
   - Edge case tests (null, empty, boundary values)
   - Error case tests (exceptions, validation failures)
   - Boundary condition tests
6. **Provide run instructions**:
   - C#: `dotnet test {Project}.Tests.csproj`
   - JS: `npx vitest run`
