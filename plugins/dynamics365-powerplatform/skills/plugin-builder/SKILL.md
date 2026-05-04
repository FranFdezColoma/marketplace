---
name: plugin-builder
description: Build Dynamics 365 CE plugins following enterprise patterns. Guides through project setup, implementation, registration, and testing using .NET Framework 4.7.1 and the Dynamics 365 SDK. Use when the user needs to create a new plugin, modify an existing one, or set up a plugin project.
---

# Plugin Builder for Dynamics 365 CE

## Technology Stack (MANDATORY)

| Component | Version |
|-----------|---------|
| .NET Framework | 4.7.1 |
| Microsoft.CrmSdk.CoreAssemblies | 9.0.2.x |
| MSTest.TestFramework | 2.2.10 |
| MSTest.TestAdapter | 2.2.10 |
| Moq | 4.20.72 |
| Castle.Core | 5.1.1 |

---

### Plugin .csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net471</TargetFramework>
    <AssemblyName>[ProjectName]</AssemblyName>
    <RootNamespace>[ProjectName]</RootNamespace>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>Key.snk</AssemblyOriginatorKeyFile>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.*" />
  </ItemGroup>
</Project>
```

### Test .csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net471</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.*" />
    <PackageReference Include="MSTest.TestFramework" Version="2.2.10" />
    <PackageReference Include="MSTest.TestAdapter" Version="2.2.10" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
    <PackageReference Include="Moq" Version="4.20.72" />
    <PackageReference Include="Castle.Core" Version="5.1.1" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\[ProjectName]\[ProjectName].csproj" />
  </ItemGroup>
</Project>
```

---

## Plugin Pattern

Two-class structure in a **single file**: a thin `IPlugin` entry point that resolves services and dispatches, and an `internal` Handler class that contains all business logic (enabling constructor injection for unit tests).

```csharp
// [PluginName].cs — IPlugin entry point + internal Handler (same file)
using System;
using Microsoft.Xrm.Sdk;

namespace [PluginProject]
{
    /// <summary>
    /// Plugin triggered on [Message] of [Entity] ([Stage]).
    /// Business rule: [Description]
    /// Registration: [Entity] | [Message] | [Stage] | [Mode]
    /// Filtering Attributes: [list or "none"]
    /// </summary>
    public class [PluginName] : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = serviceFactory.CreateOrganizationService(context.UserId);

            tracingService.Trace("{0}: Start. Message={1}, Stage={2}, UserId={3}",
                nameof([PluginName]), context.MessageName, context.Stage, context.UserId);

            try
            {
                var handler = new [PluginName]Handler(service, tracingService);
                handler.Execute(context);

                tracingService.Trace("{0}: Completed successfully.", nameof([PluginName]));
            }
            catch (InvalidPluginExecutionException)
            {
                throw;
            }
            catch (Exception ex)
            {
                tracingService.Trace("{0}: Unhandled exception. {1}", nameof([PluginName]), ex);
                throw new InvalidPluginExecutionException(
                    $"Unexpected error in {nameof([PluginName])}: {ex.Message}", ex);
            }
        }
    }

    /// <summary>
    /// Handles the business logic for [PluginName].
    /// Internal to prevent direct instantiation outside the plugin assembly.
    /// </summary>
    internal class [PluginName]Handler
    {
        private readonly IOrganizationService _service;
        private readonly ITracingService _tracingService;

        internal [PluginName]Handler(IOrganizationService service, ITracingService tracingService)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _tracingService = tracingService ?? throw new ArgumentNullException(nameof(tracingService));
        }

        /// <summary>
        /// Executes the business logic. Validates input and performs the operation.
        /// </summary>
        internal void Execute(IPluginExecutionContext context)
        {
            if (context.Depth > 3)
            {
                _tracingService.Trace("[PluginName]Handler: Skipping — depth limit exceeded ({0}).", context.Depth);
                return;
            }

            if (!context.InputParameters.Contains("Target") ||
                !(context.InputParameters["Target"] is Entity target))
            {
                throw new InvalidPluginExecutionException("Target entity not found in InputParameters.");
            }

            _tracingService.Trace("[PluginName]Handler: Processing {0} ({1}).", target.LogicalName, target.Id);

            // TODO: Implement business logic here

            _tracingService.Trace("[PluginName]Handler: Done.");
        }
    }
}
```

---

## Registration Guide

| Property | Values |
|----------|--------|
| Message | Create, Update, Delete, Retrieve, RetrieveMultiple, Associate, Disassociate, SetState |
| Stage | PreValidation (10), PreOperation (20), PostOperation (40) |
| Mode | Synchronous, Asynchronous |
| Filtering | Comma-separated attributes (Update only) |
| Images | Pre: snapshot before op; Post: snapshot after op |

### Stage Selection

| Use Case | Stage | Mode |
|----------|-------|------|
| Input validation, cancel operation | PreValidation | Sync |
| Auto-populate fields before save | PreOperation | Sync |
| Create related records | PostOperation | Sync |
| External integration, notifications | PostOperation | Async |

---

## Build Commands

```powershell
msbuild /p:Configuration=Release [SolutionName].sln
dotnet test [TestProject].csproj --verbosity normal
sn -k Key.snk  # first time only
pac plugin push --assembly bin\Release\net471\[Assembly].dll
```

---

## Anti-Patterns (NEVER DO)

1. Static mutable state — instances shared across threads
2. Thread/Task — not supported in sandbox
3. System.IO/System.Net — not permitted
4. Thread.Sleep — wastes execution time
5. ColumnSet(true) — always specify columns
6. Catch without re-throw — handle or propagate
7. Hardcoded GUIDs — use queries or config
8. Direct DB access — use SDK only
9. Ignoring Depth — causes infinite recursion

---

## Resources

- `./reference/plugin-architecture.md` — Architecture patterns
- `./scripts/scaffold-plugin.ps1` — Automated project scaffolding
