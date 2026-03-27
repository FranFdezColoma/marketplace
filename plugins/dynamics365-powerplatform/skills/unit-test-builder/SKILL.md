---
name: unit-test-builder
description: Genera tests unitarios completos y listos para ejecutar. Para C# usa MSTest + Moq (patrón de plugins Dataverse). Para JavaScript/TypeScript usa Vitest + xrm-mock (para Form Scripts y Web Resources de Dynamics 365/Power Apps). Cubre Arrange/Act/Assert, mocks de servicios Dataverse, casos felices y casos de error. Úsalo cuando el usuario necesite "crea tests unitarios", "añade tests a este plugin", "tests para este form script", "cobertura de tests", "unit tests c#", "unit tests vitest", "testea esta función".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. For C# tests requires dotnet >= 4.7.1. For JS/TS tests requires Node.js >= 16 and vitest.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[fichero o función a testear; o 'plugin c#' / 'form script js' para indicar el tipo]"
---

# Unit Test Builder — C# y JavaScript/TypeScript

**Triggers**: unit-test-builder, crea tests unitarios, añade tests, cobertura de tests, tests para este plugin
**Aliases**: /test, /unit-test-builder, /tests

## Referencias

- **Patrones Dataverse**: [dataverse-patterns.md](../../references/dataverse-patterns.md)
- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)

---

## Instrucciones

### Paso 1: Identificar el Tipo de Tests

Lee el código proporcionado o usa `AskUserQuestion` para determinar:

1. **¿C# o JavaScript/TypeScript?**
2. **¿Qué fichero/función/clase se va a testear?**
3. **¿Existen ya tests? ¿Necesitas ampliarlos o crearlos desde cero?**

Lee el código a testear antes de generar los tests. Entiende la lógica de negocio para crear casos de prueba significativos.

---

## Tests Unitarios en C# — MSTest + Moq

### Stack requerido

```xml
<!-- packages.config del proyecto de tests -->
<packages>
  <package id="Microsoft.CrmSdk.CoreAssemblies" version="9.0.2.60" targetFramework="net471" />
  <package id="MSTest.TestFramework" version="2.2.10" targetFramework="net471" />
  <package id="MSTest.TestAdapter" version="2.2.10" targetFramework="net471" />
  <package id="Moq" version="4.20.72" targetFramework="net471" />
  <package id="Castle.Core" version="5.1.1" targetFramework="net471" />
</packages>
```

### Estructura del proyecto de tests

```
[PluginProjectName].Tests/
├── [PluginProjectName].Tests.csproj   # TargetFrameworkVersion v4.7.1
├── [PluginName]Tests.cs
├── Properties/
│   └── AssemblyInfo.cs
├── app.config
└── packages.config
```

### Plantilla base — Plugin Dataverse

```csharp
// [PluginName]Tests.cs
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
        // ─── Mocks ────────────────────────────────────────────────────────────
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

        // ─── Tests ────────────────────────────────────────────────────────────

        /// <summary>Happy path: input válido, comportamiento esperado.</summary>
        [TestMethod]
        public void Execute_WithValidInput_CompletesSuccessfully()
        {
            // Arrange
            var entityId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", entityId);
            target["[attribute]"] = "[valid_value]";

            SetupContextMocks("Create", "[entity_logical_name]", entityId, target);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockOrgService.Verify(x => x.Update(It.IsAny<Entity>()), Times.Once);
            _mockTracingService.Verify(x => x.Trace(It.IsAny<string>(), It.IsAny<object[]>()), Times.AtLeastOnce);
        }

        /// <summary>Input inválido: debe lanzar InvalidPluginExecutionException.</summary>
        [TestMethod]
        public void Execute_WithInvalidInput_ThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var entityId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", entityId);
            target["[attribute]"] = "[invalid_value]";

            SetupContextMocks("Create", "[entity_logical_name]", entityId, target);
            SetupServiceProvider();

            // Act & Assert
            Assert.ThrowsException<InvalidPluginExecutionException>(() =>
                _plugin.Execute(_mockServiceProvider.Object));
        }

        /// <summary>Entidad incorrecta: el plugin debe ignorar y no hacer nada.</summary>
        [TestMethod]
        public void Execute_WithWrongEntityName_ReturnsEarly()
        {
            // Arrange
            var entityId = Guid.NewGuid();
            var target = new Entity("account", entityId);

            _mockContext.Setup(x => x.MessageName).Returns("Create");
            _mockContext.Setup(x => x.PrimaryEntityName).Returns("account");
            _mockContext.Setup(x => x.InputParameters).Returns(new ParameterCollection { { "Target", target } });
            _mockContext.Setup(x => x.UserId).Returns(entityId);

            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockOrgService.Verify(x => x.RetrieveMultiple(It.IsAny<QueryExpression>()), Times.Never);
        }

        /// <summary>Target no es Entity: el plugin debe ignorar y no hacer nada.</summary>
        [TestMethod]
        public void Execute_WithInvalidTargetParameter_ReturnsEarly()
        {
            // Arrange
            var userId = Guid.NewGuid();

            _mockContext.Setup(x => x.MessageName).Returns("Create");
            _mockContext.Setup(x => x.PrimaryEntityName).Returns("[entity_logical_name]");
            _mockContext.Setup(x => x.InputParameters).Returns(new ParameterCollection { { "Target", "invalid" } });
            _mockContext.Setup(x => x.UserId).Returns(userId);

            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockOrgService.Verify(x => x.RetrieveMultiple(It.IsAny<QueryExpression>()), Times.Never);
        }

        /// <summary>El servicio lanza una excepción inesperada: debe envolverse en InvalidPluginExecutionException.</summary>
        [TestMethod]
        public void Execute_WhenServiceThrowsUnexpectedException_ThrowsInvalidPluginExecutionException()
        {
            // Arrange
            var entityId = Guid.NewGuid();
            var target = new Entity("[entity_logical_name]", entityId);
            target["[attribute]"] = "[valid_value]";

            SetupContextMocks("Create", "[entity_logical_name]", entityId, target);
            SetupServiceProvider();

            _mockOrgService.Setup(x => x.RetrieveMultiple(It.IsAny<QueryExpression>()))
                .Throws(new Exception("Unexpected service error"));

            // Act & Assert
            Assert.ThrowsException<InvalidPluginExecutionException>(() =>
                _plugin.Execute(_mockServiceProvider.Object));
        }

        // ─── Helper Methods ───────────────────────────────────────────────────

        #region Helper Methods

        private void SetupContextMocks(string message, string entityName, Guid entityId, Entity target)
        {
            _mockContext.Setup(x => x.MessageName).Returns(message);
            _mockContext.Setup(x => x.PrimaryEntityName).Returns(entityName);
            _mockContext.Setup(x => x.PrimaryEntityId).Returns(entityId);
            _mockContext.Setup(x => x.InputParameters).Returns(
                new ParameterCollection { { "Target", target } });
            _mockContext.Setup(x => x.UserId).Returns(Guid.NewGuid());
            _mockContext.Setup(x => x.Stage).Returns(40); // Post-operation
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

### Compilar y ejecutar tests C#

```powershell
# Compilar proyecto de tests
msbuild ./[PluginName].Tests/[PluginName].Tests.csproj /p:Configuration=Debug

# Ejecutar tests con VSTest
vstest.console.exe ./[PluginName].Tests/bin/Debug/[PluginName].Tests.dll /Logger:trx

# Ver resultados
# Los ficheros .trx se generan en TestResults/
```

### Convenciones de naming para tests C#

| Patrón | Ejemplo |
|--------|---------|
| `MethodName_StateUnderTest_ExpectedBehavior` | `Execute_WithNullCountry_ReturnsEarly` |
| Happy path | `Execute_WithValidInput_CompletesSuccessfully` |
| Error path | `Execute_WithNegativeAmount_ThrowsException` |
| Guard clause | `Execute_WithWrongEntity_ReturnsEarly` |
| Service failure | `Execute_WhenServiceThrows_WrapsInInvalidPluginException` |

---

## Tests Unitarios en JavaScript/TypeScript — Vitest + xrm-mock

### Stack requerido

```json
// package.json (dependencias de desarrollo)
{
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vitest/coverage-v8": "^1.0.0",
    "xrm-mock": "^3.7.0"
  },
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

```js
// vitest.config.js
import { defineConfig } from "vitest/config";

export default defineConfig({
    test: {
        globals: true,
        environment: "jsdom",
        coverage: {
            provider: "v8",
            reporter: ["text", "lcov"],
            thresholds: {
                lines: 80,
                functions: 80,
                branches: 75
            }
        }
    }
});
```

### Plantilla base — Form Script / Web Resource

```javascript
// [ModuleName].test.js
/**
 * [ModuleName].test.js
 * Vitest unit tests for [ModuleName].js using xrm-mock
 *
 * Coverage targets: >80% lines, >80% functions
 */

import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { XrmMockGenerator } from "xrm-mock";
import {
    // Importa las funciones exportadas del módulo bajo prueba
    onLoad,
    onSave,
    // ... otras funciones
} from "./[ModuleName].js";

describe("[ModuleName] - Unit Tests (xrm-mock)", () => {

    // ─── Setup / Teardown ────────────────────────────────────────────────────

    beforeEach(() => {
        // Reinicializar el entorno xrm-mock para cada test
        XrmMockGenerator.initialise();

        // Crear atributos del formulario
        XrmMockGenerator.Attribute.createString("[attribute_name]", "default_value");
        XrmMockGenerator.Attribute.createOptionSet("[optionset_name]", 100000000);
        XrmMockGenerator.Attribute.createLookup("[lookup_name]", null);
        XrmMockGenerator.Attribute.createBoolean("[boolean_name]", false);

        // Crear controles del formulario
        XrmMockGenerator.Control.createString({ name: "[attribute_name]", visible: true });

        // Mock de Xrm.WebApi
        global.Xrm.WebApi = {
            retrieveRecord: vi.fn().mockResolvedValue({}),
            retrieveMultipleRecords: vi.fn().mockResolvedValue({ entities: [] }),
            createRecord: vi.fn().mockResolvedValue({ id: "new-record-id" }),
            updateRecord: vi.fn().mockResolvedValue({}),
            deleteRecord: vi.fn().mockResolvedValue({})
        };

        // Mock de Xrm.Navigation
        global.Xrm.Navigation = {
            openAlertDialog: vi.fn().mockResolvedValue({}),
            openConfirmDialog: vi.fn().mockResolvedValue({ confirmed: true }),
            openErrorDialog: vi.fn(),
            navigateTo: vi.fn()
        };

        // Mock de Xrm.Utility
        global.Xrm.Utility = {
            showProgressIndicator: vi.fn(),
            closeProgressIndicator: vi.fn(),
            getEntityMetadata: vi.fn()
        };
    });

    afterEach(() => {
        vi.clearAllMocks();
    });

    // ─── Tests del ciclo de vida del formulario ───────────────────────────────

    describe("onLoad", () => {
        it("should execute without errors on form load", async () => {
            // Arrange
            const executionContext = XrmMockGenerator.getEventContext();

            // Act & Assert
            await expect(onLoad(executionContext)).resolves.not.toThrow();
        });

        it("should set field visibility on load", async () => {
            // Arrange
            const executionContext = XrmMockGenerator.getEventContext();

            // Act
            await onLoad(executionContext);

            // Assert
            const control = Xrm.Page.ui.controls.get("[attribute_name]");
            // Ajusta el assert según la lógica real del formulario
            expect(control).toBeDefined();
        });
    });

    // ─── Tests de funciones de negocio ────────────────────────────────────────

    describe("[functionName]", () => {
        it("should return expected result with valid input", async () => {
            // Arrange
            global.Xrm.WebApi.retrieveRecord.mockResolvedValue({
                "[field]": "expected_value"
            });

            // Act
            // const result = await functionName(params);

            // Assert
            // expect(result).toBe("expected_value");
            expect(global.Xrm.WebApi.retrieveRecord).toHaveBeenCalledOnce();
        });

        it("should handle API error gracefully", async () => {
            // Arrange
            global.Xrm.WebApi.retrieveRecord.mockRejectedValue(
                new Error("API Error")
            );

            // Act & Assert
            // await expect(functionName(params)).rejects.toThrow("API Error");
            // O verificar que muestra notificación de error:
            // expect(global.Xrm.Navigation.openErrorDialog).toHaveBeenCalledOnce();
        });

        it("should do nothing when required attribute is null", async () => {
            // Arrange
            XrmMockGenerator.Attribute.createLookup("[lookup_name]", null);

            // Act
            // await functionName(XrmMockGenerator.getEventContext());

            // Assert
            expect(global.Xrm.WebApi.retrieveRecord).not.toHaveBeenCalled();
        });
    });
});
```

### Ejecutar tests JS/TS

```powershell
# Ejecutar todos los tests
npm test

# Con cobertura
npm run test:coverage

# Modo watch (desarrollo)
npm run test:watch

# Tests específicos
npx vitest run [ModuleName].test.js
```

### Convenciones para tests JS/TS

| Patrón | Ejemplo |
|--------|---------|
| Describe por función/módulo | `describe("onLoad", () => {...})` |
| Caso feliz | `it("should load form data on initialization", ...)` |
| Caso de error | `it("should display error when API call fails", ...)` |
| Guard clause | `it("should do nothing when lookup is null", ...)` |
| Mock verificado | `expect(vi.fn()).toHaveBeenCalledWith(expected)` |

---

### Paso Final: Verificar Cobertura

```powershell
# C# — con dotnet test (si el proyecto usa SDK-style .csproj)
dotnet test --collect:"XPlat Code Coverage"

# JS/TS — cobertura con Vitest
npm run test:coverage
# Revisar: coverage/index.html
```

**Objetivo mínimo de cobertura:**
- Lógica de negocio crítica: **≥ 80%** de líneas y funciones
- Casos de error y guard clauses siempre cubiertos
