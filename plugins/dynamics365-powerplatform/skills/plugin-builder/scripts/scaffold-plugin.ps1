<#
.SYNOPSIS
    Scaffolds a D365 CE plugin project (.NET 4.7.1) with MSTest+Moq test project, handler, and .sln.
.EXAMPLE
    .\scaffold-plugin.ps1 -CompanyName "Contoso" -ProjectName "CRM" -EntityName "account" -MessageName "Create"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CompanyName,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$EntityName,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Create", "Update", "Delete")]
    [string]$MessageName = "Create",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

$ErrorActionPreference = "Stop"

$namespace = "$CompanyName.$ProjectName.Plugins"
$testNamespace = "$namespace.Tests"
$entityPascal = (Get-Culture).TextInfo.ToTitleCase($EntityName)
$handlerName = "${MessageName}${entityPascal}Handler"
$solutionDir = Join-Path $OutputPath "$CompanyName.$ProjectName"

# Create directory structure
$pluginDir = Join-Path $solutionDir "$namespace"
$testDir = Join-Path $solutionDir "$testNamespace"

$dirs = @(
    "$pluginDir\Handlers\$entityPascal",
    "$pluginDir\Services",
    "$pluginDir\Properties",
    "$testDir\Helpers",
    "$testDir\Handlers\$entityPascal"
)

foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

# Generate strong name key
$keyPath = Join-Path $pluginDir "Key.snk"
if (Get-Command "sn" -ErrorAction SilentlyContinue) {
    sn -k $keyPath 2>$null
} else {
    Write-Warning "sn.exe not found. Please generate Key.snk manually: sn -k Key.snk"
}

# Plugin .csproj
$pluginCsproj = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net471</TargetFramework>
    <AssemblyName>$namespace</AssemblyName>
    <RootNamespace>$namespace</RootNamespace>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>Key.snk</AssemblyOriginatorKeyFile>
    <LangVersion>latest</LangVersion>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.*" />
  </ItemGroup>
</Project>
"@
Set-Content -Path (Join-Path $pluginDir "$namespace.csproj") -Value $pluginCsproj -Encoding UTF8

# Test .csproj
$testCsproj = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net471</TargetFramework>
    <RootNamespace>$testNamespace</RootNamespace>
    <IsPackable>false</IsPackable>
    <LangVersion>latest</LangVersion>
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
    <ProjectReference Include="..\$namespace\$namespace.csproj" />
  </ItemGroup>
</Project>
"@
Set-Content -Path (Join-Path $testDir "$testNamespace.csproj") -Value $testCsproj -Encoding UTF8

# Handler class (IPlugin entry point + internal Handler in the same file)
$handler = @"
using Microsoft.Xrm.Sdk;
using System;

namespace ${namespace}.Handlers.${entityPascal}
{
    /// <summary>
    /// Plugin triggered on ${MessageName} of ${EntityName}.
    /// Registration: ${EntityName} | ${MessageName} | [Stage] | [Mode]
    /// Filtering Attributes: [list or "none"]
    /// </summary>
    public class ${handlerName} : IPlugin
    {
        /// <summary>
        /// Resolves plugin services and dispatches to the internal handler.
        /// </summary>
        public void Execute(IServiceProvider serviceProvider)
        {
            if (serviceProvider == null)
                throw new ArgumentNullException(nameof(serviceProvider));

            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = serviceFactory.CreateOrganizationService(context.UserId);

            tracingService.Trace(`$"${handlerName}: Start. Message={context.MessageName}, Stage={context.Stage}, Depth={context.Depth}");

            try
            {
                var handler = new ${handlerName}BusinessLogic(service, tracingService);
                handler.Execute(context);

                tracingService.Trace(`$"${handlerName}: Completed successfully.");
            }
            catch (InvalidPluginExecutionException) { throw; }
            catch (Exception ex)
            {
                tracingService.Trace(`$"${handlerName}: Unhandled exception. {ex}");
                throw new InvalidPluginExecutionException(
                    `$"An unexpected error occurred in ${handlerName}. Please contact your administrator.", ex);
            }
        }
    }

    /// <summary>
    /// Contains the business logic for ${handlerName}.
    /// Internal to prevent direct instantiation outside the assembly.
    /// </summary>
    internal class ${handlerName}BusinessLogic
    {
        private readonly IOrganizationService _service;
        private readonly ITracingService _tracingService;

        internal ${handlerName}BusinessLogic(IOrganizationService service, ITracingService tracingService)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _tracingService = tracingService ?? throw new ArgumentNullException(nameof(tracingService));
        }

        /// <summary>
        /// Validates input and executes the ${EntityName} ${MessageName} business logic.
        /// </summary>
        internal void Execute(IPluginExecutionContext context)
        {
            if (context.Depth > 3)
            {
                _tracingService.Trace(`$"${handlerName}BusinessLogic: Skipping - depth limit exceeded ({context.Depth}).");
                return;
            }

            if (context.MessageName != "${MessageName}") return;

            if (!context.InputParameters.Contains("Target") ||
                !(context.InputParameters["Target"] is Entity target))
            {
                throw new InvalidPluginExecutionException("Target entity not found.");
            }

            _tracingService.Trace(`$"${handlerName}BusinessLogic: Processing ${EntityName} ({target.Id}).");

            // TODO: Implement business logic here

            _tracingService.Trace(`$"${handlerName}BusinessLogic: Done.");
        }
    }
}
"@
Set-Content -Path (Join-Path $pluginDir "Handlers\$entityPascal\${handlerName}.cs") -Value $handler -Encoding UTF8

# Test Helper
$testHelper = @"
using Microsoft.Xrm.Sdk;
using Moq;
using System;

namespace ${testNamespace}.Helpers
{
    public static class PluginTestHelper
    {
        public static (Mock<IServiceProvider> ServiceProvider,
                       Mock<IPluginExecutionContext> Context,
                       Mock<IOrganizationService> Service,
                       Mock<ITracingService> TracingService)
            CreateMockServices(string messageName = "Create", string entityName = "${EntityName}", int depth = 1)
        {
            var mockService = new Mock<IOrganizationService>();
            var mockContext = new Mock<IPluginExecutionContext>();
            var mockTracingService = new Mock<ITracingService>();
            var mockServiceFactory = new Mock<IOrganizationServiceFactory>();
            var mockServiceProvider = new Mock<IServiceProvider>();

            mockContext.Setup(c => c.MessageName).Returns(messageName);
            mockContext.Setup(c => c.PrimaryEntityName).Returns(entityName);
            mockContext.Setup(c => c.Depth).Returns(depth);
            mockContext.Setup(c => c.InputParameters).Returns(new ParameterCollection());
            mockContext.Setup(c => c.OutputParameters).Returns(new ParameterCollection());
            mockContext.Setup(c => c.PreEntityImages).Returns(new EntityImageCollection());
            mockContext.Setup(c => c.PostEntityImages).Returns(new EntityImageCollection());
            mockContext.Setup(c => c.SharedVariables).Returns(new ParameterCollection());

            mockServiceFactory
                .Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                .Returns(mockService.Object);

            mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
                .Returns(mockContext.Object);
            mockServiceProvider
                .Setup(sp => sp.GetService(typeof(ITracingService)))
                .Returns(mockTracingService.Object);
            mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(mockServiceFactory.Object);

            return (mockServiceProvider, mockContext, mockService, mockTracingService);
        }
    }
}
"@
Set-Content -Path (Join-Path $testDir "Helpers\PluginTestHelper.cs") -Value $testHelper -Encoding UTF8

# Test class
$testClass = @"
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;
using System;
using ${namespace}.Handlers.${entityPascal};
using ${testNamespace}.Helpers;

namespace ${testNamespace}.Handlers.${entityPascal}
{
    [TestClass]
    public class ${handlerName}Tests
    {
        [TestMethod]
        public void WhenTargetEntityProvided_ThenExecutesSuccessfully()
        {
            // Arrange
            var (serviceProvider, context, service, tracing) =
                PluginTestHelper.CreateMockServices("${MessageName}", "${EntityName}");

            var target = new Entity("${EntityName}", Guid.NewGuid());
            context.Object.InputParameters["Target"] = target;

            var plugin = new ${handlerName}();

            // Act
            plugin.Execute(serviceProvider.Object);

            // Assert
            tracing.Verify(t => t.Trace(It.IsAny<string>(), It.IsAny<object[]>()), Times.AtLeastOnce);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void WhenTargetMissing_ThenThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var (serviceProvider, context, service, tracing) =
                PluginTestHelper.CreateMockServices("${MessageName}", "${EntityName}");

            // No Target in InputParameters
            var plugin = new ${handlerName}();

            // Act — expects InvalidPluginExecutionException from the Handler
            plugin.Execute(serviceProvider.Object);
        }

        [TestMethod]
        public void WhenDepthExceedsLimit_ThenSkipsExecution()
        {
            // Arrange
            var (serviceProvider, context, service, tracing) =
                PluginTestHelper.CreateMockServices("${MessageName}", "${EntityName}", depth: 4);

            var target = new Entity("${EntityName}", Guid.NewGuid());
            context.Object.InputParameters["Target"] = target;

            var plugin = new ${handlerName}();

            // Act
            plugin.Execute(serviceProvider.Object);

            // Assert — no SDK calls when depth guard triggers
            service.Verify(s => s.Create(It.IsAny<Entity>()), Times.Never);
            service.Verify(s => s.Update(It.IsAny<Entity>()), Times.Never);
        }
    }
}
"@
Set-Content -Path (Join-Path $testDir "Handlers\$entityPascal\${handlerName}Tests.cs") -Value $testClass -Encoding UTF8

# Solution file
$pluginGuid = [guid]::NewGuid().ToString("B").ToUpper()
$testGuid = [guid]::NewGuid().ToString("B").ToUpper()
$slnContent = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "$namespace", "$namespace\$namespace.csproj", "$pluginGuid"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "$testNamespace", "$testNamespace\$testNamespace.csproj", "$testGuid"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		$pluginGuid.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		$pluginGuid.Debug|Any CPU.Build.0 = Debug|Any CPU
		$pluginGuid.Release|Any CPU.ActiveCfg = Release|Any CPU
		$pluginGuid.Release|Any CPU.Build.0 = Release|Any CPU
		$testGuid.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		$testGuid.Debug|Any CPU.Build.0 = Debug|Any CPU
		$testGuid.Release|Any CPU.ActiveCfg = Release|Any CPU
		$testGuid.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
"@
Set-Content -Path (Join-Path $solutionDir "$CompanyName.$ProjectName.sln") -Value $slnContent -Encoding UTF8

Write-Host "`nScaffolded: $solutionDir" -ForegroundColor Green
Write-Host "  Plugin: $namespace | Test: $testNamespace | Handler: ${handlerName}"
Write-Host "Next: cd $solutionDir && dotnet restore && dotnet build && dotnet test" -ForegroundColor Yellow
