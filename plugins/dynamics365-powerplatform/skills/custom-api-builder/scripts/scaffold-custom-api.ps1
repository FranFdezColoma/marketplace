<#
.SYNOPSIS
    Scaffolds a new Dataverse Custom API project structure.

.DESCRIPTION
    Creates the folder structure, plugin class file, unit test file,
    and metadata registration file for a new Custom API.

.PARAMETER ApiName
    The name of the Custom API (without publisher prefix).

.PARAMETER Namespace
    The root namespace for the project.

.PARAMETER PublisherPrefix
    The publisher prefix (e.g., "contoso").

.PARAMETER BindingType
    The binding type: Global, Entity, or EntityCollection.

.PARAMETER BoundEntity
    The entity logical name (required if BindingType is Entity or EntityCollection).

.PARAMETER IsFunction
    Whether the API is a function (read-only, GET) or action (side effects, POST).

.PARAMETER OutputPath
    The output directory. Defaults to current directory.

.EXAMPLE
    .\scaffold-custom-api.ps1 -ApiName "CalculateDiscount" -Namespace "Contoso.Plugins" -PublisherPrefix "contoso"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ApiName,

    [Parameter(Mandatory = $true)]
    [string]$Namespace,

    [Parameter(Mandatory = $true)]
    [string]$PublisherPrefix,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Global", "Entity", "EntityCollection")]
    [string]$BindingType = "Global",

    [Parameter(Mandatory = $false)]
    [string]$BoundEntity = "",

    [Parameter(Mandatory = $false)]
    [switch]$IsFunction,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

$ErrorActionPreference = "Stop"

# Validate parameters
if ($BindingType -ne "Global" -and [string]::IsNullOrWhiteSpace($BoundEntity)) {
    throw "BoundEntity is required when BindingType is '$BindingType'."
}

$fullApiName = "${PublisherPrefix}_${ApiName}"
$pluginClassName = "${ApiName}Plugin"
$testClassName = "${ApiName}PluginTests"

# Create directory structure
$pluginDir = Join-Path $OutputPath "Plugins\CustomApis"
$testDir = Join-Path $OutputPath "Plugins.Tests\CustomApis"

New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
New-Item -ItemType Directory -Force -Path $testDir | Out-Null

# Generate plugin class
$pluginContent = @"
using Microsoft.Xrm.Sdk;
using System;

namespace ${Namespace}.Plugins.CustomApis
{
    /// <summary>
    /// Implements the ${fullApiName} Custom API.
    /// </summary>
    public class ${pluginClassName} : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = serviceFactory.CreateOrganizationService(context.UserId);

            try
            {
                tracingService.Trace("${pluginClassName}: Execution started.");

                // TODO: Extract and validate input parameters from context.InputParameters

                // TODO: Implement business logic

                // TODO: Set output parameters in context.OutputParameters

                tracingService.Trace("${pluginClassName}: Execution completed successfully.");
            }
            catch (InvalidPluginExecutionException)
            {
                throw;
            }
            catch (Exception ex)
            {
                tracingService.Trace(`$"${pluginClassName}: Unexpected error - {ex.Message}");
                throw new InvalidPluginExecutionException(
                    "An error occurred while executing ${ApiName}. Please contact your administrator.",
                    ex);
            }
        }
    }
}
"@

# Generate test class
$testContent = @"
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;
using System;
using ${Namespace}.Plugins.CustomApis;

namespace ${Namespace}.Plugins.Tests.CustomApis
{
    [TestClass]
    public class ${testClassName}
    {
        private Mock<IOrganizationService> _mockService;
        private Mock<IPluginExecutionContext> _mockContext;
        private Mock<ITracingService> _mockTracingService;
        private Mock<IOrganizationServiceFactory> _mockServiceFactory;
        private Mock<IServiceProvider> _mockServiceProvider;

        [TestInitialize]
        public void Setup()
        {
            _mockService = new Mock<IOrganizationService>();
            _mockContext = new Mock<IPluginExecutionContext>();
            _mockTracingService = new Mock<ITracingService>();
            _mockServiceFactory = new Mock<IOrganizationServiceFactory>();
            _mockServiceProvider = new Mock<IServiceProvider>();

            _mockServiceFactory
                .Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                .Returns(_mockService.Object);

            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
                .Returns(_mockContext.Object);
            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(ITracingService)))
                .Returns(_mockTracingService.Object);
            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(_mockServiceFactory.Object);

            _mockContext.Setup(c => c.InputParameters).Returns(new ParameterCollection());
            _mockContext.Setup(c => c.OutputParameters).Returns(new ParameterCollection());
        }

        [TestMethod]
        public void WhenValidInput_ThenExecutesSuccessfully()
        {
            // Arrange
            // TODO: Set up input parameters
            var plugin = new ${pluginClassName}();

            // Act
            plugin.Execute(_mockServiceProvider.Object);

            // Assert
            // TODO: Verify output parameters and service calls
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void WhenInvalidInput_ThenThrowsException()
        {
            // Arrange - missing required parameters
            var plugin = new ${pluginClassName}();

            // Act
            plugin.Execute(_mockServiceProvider.Object);
        }
    }
}
"@

# Write files
$pluginFile = Join-Path $pluginDir "${pluginClassName}.cs"
$testFile = Join-Path $testDir "${testClassName}.cs"

Set-Content -Path $pluginFile -Value $pluginContent -Encoding UTF8
Set-Content -Path $testFile -Value $testContent -Encoding UTF8

Write-Host "Custom API scaffolded successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:"
Write-Host "  Plugin:  $pluginFile"
Write-Host "  Tests:   $testFile"
Write-Host ""
Write-Host "Custom API Metadata:"
Write-Host "  Unique Name:  $fullApiName"
Write-Host "  Binding Type: $BindingType"
Write-Host "  Is Function:  $($IsFunction.IsPresent)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Implement business logic in the plugin class"
Write-Host "  2. Add input/output parameter definitions"
Write-Host "  3. Complete unit tests"
Write-Host "  4. Register the Custom API in your solution"
Write-Host "  5. Register the plugin assembly"
