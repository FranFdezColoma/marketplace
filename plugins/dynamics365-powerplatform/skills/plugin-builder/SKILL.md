---
name: plugin-builder
description: Crea un plugin C# para Dataverse siguiendo todas las mejores prácticas. Genera el proyecto .NET completo con IPlugin, ITracingService, Early Bound types, manejo de errores, logging y tests unitarios con MSTest y Moq. Úsalo cuando el usuario necesite "crea un plugin", "plugin dataverse", "lógica de negocio en el servidor", "plugin c#", "pre/post operation plugin", "validación en servidor".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires dotnet >= 6.0 and PAC CLI >= 2.3.1.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[descripción del plugin: tabla, mensaje, stage, lógica requerida]"
---

# Dataverse Plugin Builder

**Triggers**: plugin-builder, crea un plugin, plugin dataverse, plugin c#, lógica de negocio servidor
**Aliases**: /plugin, /plugin-builder, /dataverse-plugin

## Referencias

- **Patrones Dataverse**: [dataverse-patterns.md](../../references/dataverse-patterns.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
dotnet --version    # Debe ser >= 6.0
pac help            # Debe ser >= 2.3.1
```

Si falta algo, informa al usuario con instrucciones de instalación.

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿En qué tabla se registra el plugin?"** — Nombre lógico (ej: `opportunity`, `src_work_order`)
2. **"¿Qué mensaje/evento dispara el plugin?"** — Create, Update, Delete, Retrieve, etc.
3. **"¿Pre-operation o Post-operation?"** — Stage 20 (pre) o Stage 40 (post)
4. **"¿Síncrono o asíncrono?"** — Síncrono (modo 1) o Asíncrono (modo 2)
5. **"¿Qué lógica debe implementar?"** — Descripción de la regla de negocio
6. **"¿Hay filtering attributes?"** — Columnas que deben cambiar para activar el plugin

### Paso 3: Generar Early Bound Types

```powershell
# Verificar autenticación
pac auth list

# Generar tipos Early Bound para la entidad
pac modelbuilder build --buildertypes entity --outputDirectory ./EarlyBound --namespace Capgemini.DataModel
```

Lee los tipos generados para conocer los nombres exactos de columnas y relaciones.

### Paso 4: Crear Estructura del Proyecto


```powershell
# Crear proyecto de plugin
dotnet new classlib --name [PluginProjectName] --framework net471 --output ./src/[PluginProjectName]
cd ./src/[PluginProjectName]

# Añadir referencias NuGet
dotnet add package Microsoft.CrmSdk.CoreAssemblies --version 9.0.2.52

# Crear proyecto de tests
# Estructura del proyecto de tests:
# [PluginProjectName].Tests/
# ├── [PluginProjectName].Tests.csproj   # TargetFrameworkVersion v4.7.1
# ├── [PluginName]Tests.cs
# ├── Properties/AssemblyInfo.cs
# ├── app.config
# └── packages.config
dotnet new mstest --name [PluginProjectName].Tests --output ./tests/[PluginProjectName].Tests
cd ./tests/[PluginProjectName].Tests
dotnet add reference ../../src/[PluginProjectName]/[PluginProjectName].csproj
# Paquetes NuGet para el proyecto de tests:
# - Microsoft.CrmSdk.CoreAssemblies 9.0.2.x
# - MSTest.TestFramework 2.2.10
# - MSTest.TestAdapter 2.2.10
# - Moq 4.20.72
# - Castle.Core 5.1.1
```

### Paso 5: Generar el Código del Plugin

Genera siempre con esta estructura:

```csharp
// [PluginName].cs — Entry point (limpio, solo orquestación)
using System;
using Microsoft.Xrm.Sdk;

namespace Capgemini.[Domain]
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
                    $"Error inesperado en {nameof([PluginName])}: {ex.Message}", ex);
            }
        }
    }
}
```

```csharp
// [PluginName]Handler.cs — Lógica de negocio (testeable de forma independiente)
using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
// using [EarlyBoundNamespace]; // Añadir tras generar Early Bound

namespace Capgemini.[Domain]
{
    internal class [PluginName]Handler
    {
        private readonly IOrganizationService _service;
        private readonly ITracingService _tracingService;

        public [PluginName]Handler(IOrganizationService service, ITracingService tracingService)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _tracingService = tracingService ?? throw new ArgumentNullException(nameof(tracingService));
        }

        public void Execute(IPluginExecutionContext context)
        {
            ValidateContext(context);

            if (!context.InputParameters.TryGetValue("Target", out var targetObj) || targetObj is not Entity target)
            {
                _tracingService.Trace("Target not found or not an Entity. Skipping.");
                return;
            }

            _tracingService.Trace("Processing [Entity] Id={0}", target.Id);

            // === LÓGICA DE NEGOCIO AQUÍ ===
            Execute[BusinessLogic](target, context);
        }

        private void Execute[BusinessLogic](Entity target, IPluginExecutionContext context)
        {
            // Implementación de la regla de negocio

            // Ejemplo: validación
            if (target.TryGetAttributeValue<Money>("src_totalamount", out var totalAmount))
            {
                if (totalAmount?.Value < 0)
                {
                    throw new InvalidPluginExecutionException(
                        "El importe total no puede ser negativo. Por favor, revise el valor introducido.");
                }
            }

            // Ejemplo: enriquecimiento
            // target["src_processedon"] = DateTime.UtcNow;
        }

        private static void ValidateContext(IPluginExecutionContext context)
        {
            if (context == null)
                throw new ArgumentNullException(nameof(context));

            // Validar que el plugin se ejecuta en el contexto correcto
            if (context.MessageName != "[ExpectedMessage]")
                throw new InvalidPluginExecutionException(
                    $"Plugin registrado incorrectamente. Mensaje esperado: [ExpectedMessage], recibido: {context.MessageName}");
        }
    }
}
```

```csharp
// [PluginName]Tests.cs — Tests unitarios con MSTest + Moq
using System;
using Microsoft.Crm.Sdk.Messages;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using Moq;

namespace [ProjectNamespace].Tests
{
    [TestClass]
    public class [PluginName]Tests
    {
        private Mock<IOrganizationService> _mockOrgService;
        private Mock<ITracingService> _mockTracingService;
        private Mock<IPluginExecutionContext> _mockContext;
        private Mock<IServiceProvider> _mockServiceProvider;
        private Mock<IOrganizationServiceFactory> _mockServiceFactory;
        private [PluginName] _plugin;

        [TestInitialize]
        public void Initialize()
        {
            _mockOrgService = new Mock<IOrganizationService>();
            _mockTracingService = new Mock<ITracingService>();
            _mockContext = new Mock<IPluginExecutionContext>();
            _mockServiceProvider = new Mock<IServiceProvider>();
            _mockServiceFactory = new Mock<IOrganizationServiceFactory>();
            _plugin = new [PluginName]();
        }

        [TestMethod]
        public void Execute_WithValidInput_CompletesSuccessfully()
        {
            // Arrange
            var targetId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", targetId);
            target["[column]"] = "[valid_value]";

            SetupContextMocks("[Message]", "[entity_logical_name]", targetId, target);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockOrgService.Verify(x => x.Update(It.IsAny<Entity>()), Times.Once);
            _mockTracingService.Verify(x => x.Trace(It.IsAny<string>(), It.IsAny<object[]>()), Times.AtLeastOnce);
        }

        [TestMethod]
        public void Execute_WithInvalidInput_ThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var targetId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", targetId);
            target["[column]"] = "[invalid_value]";

            SetupContextMocks("[Message]", "[entity_logical_name]", targetId, target);
            SetupServiceProvider();

            // Act & Assert
            Assert.ThrowsException<InvalidPluginExecutionException>(() =>
            {
                _plugin.Execute(_mockServiceProvider.Object);
            });
        }

        [TestMethod]
        public void Execute_WhenServiceThrows_ThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var targetId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", targetId);
            target["[column]"] = "[valid_value]";

            SetupContextMocks("[Message]", "[entity_logical_name]", targetId, target);
            SetupServiceProvider();

            _mockOrgService.Setup(x => x.RetrieveMultiple(It.IsAny<QueryExpression>()))
                .Throws(new Exception("Service error"));

            // Act & Assert
            Assert.ThrowsException<InvalidPluginExecutionException>(() =>
            {
                _plugin.Execute(_mockServiceProvider.Object);
            });
        }

        #region Helper Methods

        private void SetupContextMocks(string message, string entityName, Guid entityId, Entity target)
        {
            _mockContext.Setup(x => x.MessageName).Returns(message);
            _mockContext.Setup(x => x.PrimaryEntityName).Returns(entityName);
            _mockContext.Setup(x => x.PrimaryEntityId).Returns(entityId);
            _mockContext.Setup(x => x.InputParameters).Returns(new ParameterCollection { { "Target", target } });
            _mockContext.Setup(x => x.UserId).Returns(Guid.NewGuid());
            _mockContext.Setup(x => x.Stage).Returns(40);
        }

        private void SetupServiceProvider()
        {
            _mockServiceFactory.Setup(x => x.CreateOrganizationService(It.IsAny<Guid?>()))
                .Returns(_mockOrgService.Object);

            _mockServiceProvider.Setup(x => x.GetService(typeof(IPluginExecutionContext)))
                .Returns(_mockContext.Object);
            _mockServiceProvider.Setup(x => x.GetService(typeof(ITracingService)))
                .Returns(_mockTracingService.Object);
            _mockServiceProvider.Setup(x => x.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(_mockServiceFactory.Object);
        }

        #endregion
    }
}
```

### Paso 6: Compilar y Ejecutar Tests

```powershell
# Compilar el proyecto principal
msbuild ./src/[PluginProjectName]/[PluginProjectName].csproj /p:Configuration=Release

# Compilar el proyecto de tests
msbuild ./tests/[PluginProjectName].Tests/[PluginProjectName].Tests.csproj /p:Configuration=Debug

# Ejecutar tests con VSTest (MSTest)
vstest.console.exe ./tests/[PluginProjectName].Tests/bin/Debug/[PluginProjectName].Tests.dll /Logger:trx

# Si los tests pasan, registrar con PAC CLI
pac plugin push --pluginFile ./src/[PluginProjectName]/bin/Release/[PluginProjectName].dll
```

### Paso 7: Registrar el Plugin

Genera la configuración de registro para **Plugin Registration Tool** o **PAC CLI**:

```
Tabla: [entity_logical_name]
Mensaje: [Message]
Stage: [Stage] ([Pre/Post-operation])
Mode: [Synchronous/Asynchronous]
Filtering Attributes: [columns] (o "none" si todos)
Run in User's Context: Calling User (por defecto)
```

### Paso 8: Resumen Final

- Código del plugin generado y guardado
- Tests ejecutados: PASS ✅
- Comando PAC CLI para registro
- Próximos pasos: code review (`/code-review`), añadir a solución, pipeline ALM (`/alm-pipeline`)
