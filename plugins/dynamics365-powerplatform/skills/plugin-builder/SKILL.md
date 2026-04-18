---
name: plugin-builder
description: 'Scaffold complete C# Dataverse plugins for Dynamics 365 with companion MSTest unit test projects. Generates production-ready code targeting .NET Framework 4.7.1 with proper error handling, tracing, and test coverage.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: code-generation
  stack: dynamics365-powerplatform
  framework: net471
---

# Plugin Builder — Dynamics 365 Dataverse

Scaffold complete C# Dataverse plugins with companion MSTest unit test projects for Dynamics 365 and Power Platform. Generates production-ready code targeting .NET Framework 4.7.1 with proper error handling, tracing, and test coverage.

## 1. Plugin Project Structure

Generate projects using this directory layout:

```
{PluginProjectName}/
├── {PluginProjectName}.csproj          # .NET Framework 4.7.1
├── Plugins/
│   ├── {PluginClassName}.cs            # Plugin implementation
│   └── ...
├── Models/
│   └── {EntityName}.cs                 # Early-bound entity (optional)
├── Services/
│   └── I{ServiceName}.cs              # Service interfaces (for testability)
│   └── {ServiceName}.cs               # Service implementations
└── Helpers/
    └── PluginBase.cs                   # Optional base class

{PluginProjectName}.Tests/
├── {PluginProjectName}.Tests.csproj    # MSTest + Moq
├── Plugins/
│   └── {PluginClassName}Tests.cs       # Plugin tests
└── Helpers/
    └── TestHelper.cs                   # Common test setup
```

Create all directories and files. Do not leave placeholder comments without implementation — generate the full working code.

## 2. Plugin Template

Use this template for every plugin class. Replace all `{placeholders}` with actual values based on user input.

```csharp
using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace {Namespace}.Plugins
{
    /// <summary>
    /// {Description of what the plugin does}
    /// Trigger: {Entity} - {Message} - {Stage}
    /// </summary>
    public class {ClassName} : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var service = factory.CreateOrganizationService(context.UserId);

            tracingService.Trace("{ClassName} plugin execution started.");

            try
            {
                // Validate context
                if (!context.InputParameters.Contains("Target") ||
                    !(context.InputParameters["Target"] is Entity target))
                {
                    tracingService.Trace("Target entity not found in InputParameters.");
                    return;
                }

                tracingService.Trace("Processing entity: {0}, Id: {1}", target.LogicalName, target.Id);

                // ── Business Logic ──────────────────────────────────────
                // TODO: Implement business logic here

                tracingService.Trace("{ClassName} plugin execution completed successfully.");
            }
            catch (InvalidPluginExecutionException)
            {
                throw; // Re-throw business exceptions
            }
            catch (Exception ex)
            {
                tracingService.Trace("Error in {ClassName}: {0}", ex.ToString());
                throw new InvalidPluginExecutionException(
                    $"An error occurred in {ClassName}. Please contact your administrator.", ex);
            }
        }
    }
}
```

### Template Rules

- Always resolve services from `IServiceProvider` — never use constructor injection.
- Always use `ITracingService` for logging — never use `Console.WriteLine` or `Debug.WriteLine`.
- Always wrap the main logic in try/catch with `InvalidPluginExecutionException`.
- Re-throw `InvalidPluginExecutionException` — never swallow it.
- For **Delete** message, `InputParameters["Target"]` is an `EntityReference`, not `Entity`. Adjust the validation accordingly:
  ```csharp
  if (!context.InputParameters.Contains("Target") ||
      !(context.InputParameters["Target"] is EntityReference targetRef))
  {
      tracingService.Trace("Target entity reference not found in InputParameters.");
      return;
  }
  ```
- For **Associate/Disassociate** messages, use `InputParameters["Relationship"]` and `InputParameters["RelatedEntities"]`.

## 3. .csproj Template

### Plugin Project

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props"
          Condition="Exists('$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props')" />
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <ProjectGuid>{NEW-GUID}</ProjectGuid>
    <OutputType>Library</OutputType>
    <RootNamespace>{Namespace}</RootNamespace>
    <AssemblyName>{PluginProjectName}</AssemblyName>
    <TargetFrameworkVersion>v4.7.1</TargetFrameworkVersion>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>{PluginProjectName}.snk</AssemblyOriginatorKeyFile>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.*" />
  </ItemGroup>
  <ItemGroup>
    <None Include="{PluginProjectName}.snk" />
  </ItemGroup>
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
</Project>
```

### Test Project

Use the same .csproj structure as the plugin project with these differences:
- `RootNamespace`: `{Namespace}.Tests`
- `AssemblyName`: `{PluginProjectName}.Tests`
- `SignAssembly`: omit (not needed for test assemblies)
- Additional NuGet packages: `MSTest.TestFramework 3.*`, `MSTest.TestAdapter 3.*`, `Moq 4.*`
- Add `ProjectReference` to the plugin project: `..\{PluginProjectName}\{PluginProjectName}.csproj`

Generate a new GUID for each `<ProjectGuid>`.

## 4. Test Project Template

### TestHelper.cs

Generate a shared test helper that mocks the full plugin pipeline:

```csharp
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;

namespace {Namespace}.Tests.Helpers
{
    public static class TestHelper
    {
        public static (
            Mock<IServiceProvider> ServiceProvider,
            Mock<IPluginExecutionContext> Context,
            Mock<IOrganizationServiceFactory> Factory,
            Mock<IOrganizationService> Service,
            Mock<ITracingService> TracingService
        ) CreatePluginMocks()
        {
            var serviceProvider = new Mock<IServiceProvider>();
            var context = new Mock<IPluginExecutionContext>();
            var factory = new Mock<IOrganizationServiceFactory>();
            var service = new Mock<IOrganizationService>();
            var tracingService = new Mock<ITracingService>();

            serviceProvider
                .Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
                .Returns(context.Object);
            serviceProvider
                .Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(factory.Object);
            serviceProvider
                .Setup(sp => sp.GetService(typeof(ITracingService)))
                .Returns(tracingService.Object);
            factory
                .Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                .Returns(service.Object);

            return (serviceProvider, context, factory, service, tracingService);
        }

        public static ParameterCollection CreateInputParameters(Entity target)
        {
            var parameters = new ParameterCollection();
            parameters.Add("Target", target);
            return parameters;
        }

        public static ParameterCollection CreateInputParameters(EntityReference targetRef)
        {
            var parameters = new ParameterCollection();
            parameters.Add("Target", targetRef);
            return parameters;
        }
    }
}
```

### Plugin Test Class

Generate tests following this pattern:

```csharp
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;
using {Namespace}.Plugins;
using {Namespace}.Tests.Helpers;

namespace {Namespace}.Tests.Plugins
{
    [TestClass]
    public class {ClassName}Tests
    {
        private Mock<IServiceProvider> _serviceProvider;
        private Mock<IPluginExecutionContext> _context;
        private Mock<IOrganizationServiceFactory> _factory;
        private Mock<IOrganizationService> _service;
        private Mock<ITracingService> _tracingService;

        [TestInitialize]
        public void Setup()
        {
            var mocks = TestHelper.CreatePluginMocks();
            _serviceProvider = mocks.ServiceProvider;
            _context = mocks.Context;
            _factory = mocks.Factory;
            _service = mocks.Service;
            _tracingService = mocks.TracingService;
        }

        [TestMethod]
        public void Execute_ValidTarget_CompletesSuccessfully()
        {
            // Arrange
            var target = new Entity("{entitylogicalname}")
            {
                Id = Guid.NewGuid()
            };
            _context.Setup(c => c.InputParameters)
                .Returns(TestHelper.CreateInputParameters(target));

            var plugin = new {ClassName}();

            // Act
            plugin.Execute(_serviceProvider.Object);

            // Assert
            _tracingService.Verify(
                t => t.Trace(It.Is<string>(s => s.Contains("completed successfully")), It.IsAny<object[]>()),
                Times.Once);
        }

        [TestMethod]
        public void Execute_MissingTarget_ReturnsWithoutProcessing()
        {
            // Arrange
            _context.Setup(c => c.InputParameters)
                .Returns(new ParameterCollection());

            var plugin = new {ClassName}();

            // Act
            plugin.Execute(_serviceProvider.Object);

            // Assert
            _tracingService.Verify(
                t => t.Trace(It.Is<string>(s => s.Contains("not found")), It.IsAny<object[]>()),
                Times.Once);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void Execute_UnexpectedException_ThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var target = new Entity("{entitylogicalname}")
            {
                Id = Guid.NewGuid()
            };
            _context.Setup(c => c.InputParameters)
                .Returns(TestHelper.CreateInputParameters(target));

            // Simulate an error in the service
            _service.Setup(s => s.Retrieve(
                    It.IsAny<string>(), It.IsAny<Guid>(), It.IsAny<Microsoft.Xrm.Sdk.Query.ColumnSet>()))
                .Throws(new Exception("Simulated error"));

            var plugin = new {ClassName}();

            // Act
            plugin.Execute(_serviceProvider.Object);
        }
    }
}
```

### Test Naming Convention

Always name tests following the pattern: `MethodName_StateUnderTest_ExpectedBehavior`

Examples:
- `Execute_ValidTarget_CompletesSuccessfully`
- `Execute_MissingTarget_ReturnsWithoutProcessing`
- `Execute_NullServiceProvider_ThrowsException`
- `Execute_DuplicateDetected_ThrowsInvalidPluginExecutionException`
- `Validate_EmptyName_ReturnsFalse`

## 5. Plugin Registration Metadata

After generating the plugin code, produce a registration summary in this format:

```
=====================================
 PLUGIN REGISTRATION METADATA
=====================================

Plugin Assembly: {Namespace}.Plugins.dll

Plugin: {Namespace}.Plugins.{ClassName}
  Message       : Create | Update | Delete | Associate | Disassociate | Retrieve | RetrieveMultiple
  Entity        : {entitylogicalname}
  Stage         : PreValidation (10) | PreOperation (20) | PostOperation (40)
  Mode          : Synchronous (0) | Asynchronous (1)
  Filtering Attrs: field1, field2  (for Update message only)
  Pre-Image     : {alias} — field1, field2
  Post-Image    : {alias} — field1, field2

=====================================
```

### Stage Guidance

| Stage | Code | Use When |
|-------|------|----------|
| PreValidation | 10 | Lightweight validation before the database transaction begins. Use for input validation, permission checks, and early rejection. |
| PreOperation | 20 | Logic that must run inside the database transaction but before the record is saved. Use for modifying the target entity, setting default values, or complex validation with data lookups. |
| PostOperation | 40 | Logic that runs after the record is saved (inside or outside the transaction). Use for creating related records, sending notifications, or triggering integrations. |

### Mode Guidance

| Mode | Code | Use When |
|------|------|----------|
| Synchronous | 0 | The user must see the result immediately, or the operation must block until complete (e.g., validation, auto-numbering). |
| Asynchronous | 1 | The operation can run in the background without blocking the user (e.g., email notifications, integration sync, heavy processing). |

## 6. Service Extraction for Testability

When business logic is complex enough to warrant service extraction, generate an interface and implementation:

### Interface

```csharp
using Microsoft.Xrm.Sdk;

namespace {Namespace}.Services
{
    public interface I{ServiceName}
    {
        /// <summary>
        /// {Description of the operation}
        /// </summary>
        {ReturnType} {MethodName}({Parameters});
    }
}
```

### Implementation

```csharp
using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace {Namespace}.Services
{
    public class {ServiceName} : I{ServiceName}
    {
        private readonly IOrganizationService _service;
        private readonly ITracingService _tracingService;

        public {ServiceName}(IOrganizationService service, ITracingService tracingService)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _tracingService = tracingService ?? throw new ArgumentNullException(nameof(tracingService));
        }

        public {ReturnType} {MethodName}({Parameters})
        {
            _tracingService.Trace("{ServiceName}.{MethodName} started.");

            // Implementation here

            _tracingService.Trace("{ServiceName}.{MethodName} completed.");
        }
    }
}
```

Use service extraction when:
- The business logic exceeds ~30 lines of code
- The same logic is needed in multiple plugins
- Complex branching or conditional logic requires dedicated unit tests
- External service calls need to be mocked independently

## 7. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Plugin class | `{Entity}{Action}{Stage}Plugin` | `AccountValidatePrePlugin` |
| Test class | `{PluginClassName}Tests` | `AccountValidatePrePluginTests` |
| Namespace | `{CompanyName}.{ProjectName}.Plugins` | `Contoso.CRM.Plugins` |
| Test namespace | `{CompanyName}.{ProjectName}.Tests` | `Contoso.CRM.Tests` |
| Service interface | `I{ServiceName}` | `IAccountValidationService` |
| Service class | `{ServiceName}` | `AccountValidationService` |
| Entity prefix | `{prefix}_` | `crb69_` (configurable per publisher) |
| Assembly name | `{CompanyName}.{ProjectName}.Plugins` | `Contoso.CRM.Plugins` |

The publisher prefix (`{prefix}_`) is configurable. Ask the user for their publisher prefix or default to the project's convention.

## 8. Workflow

Follow these steps every time you scaffold a plugin:

1. **Gather requirements** — ask the user for:
   - Entity logical name (e.g., `account`, `contact`, `crb69_customentity`)
   - Trigger message (e.g., `Create`, `Update`, `Delete`)
   - Execution stage (e.g., `PreValidation`, `PreOperation`, `PostOperation`)
   - Execution mode (`Synchronous` or `Asynchronous`)
   - Business logic description (what the plugin should do)
   - Company name and project name (for namespace)
   - Publisher prefix (for custom entity/field references)

2. **Generate the plugin class** using the template from section 2 with the business logic implemented based on the user's description.

3. **Generate the companion test class** using the template from section 4 with:
   - Happy path test (valid target, expected business logic outcome)
   - Missing target test (no `Target` in `InputParameters`)
   - Exception handling test (unexpected error wrapped in `InvalidPluginExecutionException`)
   - Additional tests specific to the business logic

4. **Generate the TestHelper.cs** if it does not already exist.

5. **Generate the .csproj files** for both the plugin project and test project if they do not already exist.

6. **Generate the registration metadata** summary from section 5.

7. **If service extraction is needed**, create the service interface, implementation, and corresponding service tests.

8. **Review the generated code** against the code-review checklist (no hardcoded GUIDs, no async/await, no Thread.Sleep, proper tracing, etc.).
