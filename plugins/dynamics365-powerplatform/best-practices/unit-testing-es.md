# Guía de Buenas Prácticas: Unit Testing en Dynamics 365 y Power Platform

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Estructura de Directorios](#estructura-de-directorios)
3. [Unit Testing para Plugins (.NET Framework)](#unit-testing-para-plugins-net-framework)
4. [Unit Testing para Web Resources (JavaScript)](#unit-testing-para-web-resources-javascript)
5. [Cobertura de Código (Code Coverage)](#cobertura-de-código-code-coverage)
6. [Buenas Prácticas](#buenas-prácticas)
7. [Troubleshooting](#troubleshooting)
8. [Integración CI/CD](#integración-cicd)

---

## Introducción

Esta guía establece el estándar para implementar **unit testing** en proyectos de Dynamics 365 y Power Platform. El objetivo es garantizar la calidad del código, reducir bugs en producción y facilitar el mantenimiento a largo plazo.

### ¿Por qué Unit Testing?

- ✅ **Calidad asegurada**: Detecta errores antes de llegar a producción
- ✅ **Refactorización segura**: Permite modificar código con confianza
- ✅ **Documentación viva**: Los tests documentan el comportamiento esperado
- ✅ **Desarrollo más rápido**: A largo plazo, reduce tiempo de debugging

### Estándar de Cobertura

> ⚠️ **CRÍTICO**: El estándar de calidad establece que **al menos el 80% del código debe estar cubierto** por tests unitarios.

---

## Estructura de Directorios

La estructura del proyecto debe seguir el siguiente patrón, donde **cada componente tiene su proyecto de tests correspondiente**:

```
Dataverse/
├── Plugins/
│   ├── <Project>.Account/
│   ├── <Project>.Account.Tests/
│   ├── <Project>.SystemUser/
│   └── <Project>.SystemUser.Tests/
│
├── CustomAPIs/
│   ├── <Project>.AppointmentScheduler.GetAvailableSlots/
│   └── <Project>.AppointmentScheduler.GetAvailableSlots.Tests/
│
├── WebResources/
│   └── <Project>.WebResources/
│        ├── Dependencies
│        └── <Publisher prefix>/
│            └── entities/
│                ├── account/
│                │   ├── account.js
│                │   └── account.test.js
│                └── systemuser/
│                    ├── systemuser.js
│                    └── systemuser.test.js
│
├── PCFs/
│   ├── AppointmentSchedulerPCF/
│   └── AppointmentSchedulerPCF.Tests/
│
└── Batches/
    ├── <Project>.Batches.Template/
    └── <Project>.Batches.Template.Tests/
```

### Principios de Organización

1. **Separación clara**: Tests junto a su código de negocio
2. **Nomenclatura consistente**: `{NombreProyecto}.Tests` para .NET
3. **JavaScript unificado**: Web Resources de negocio y tests en el mismo proyecto
4. **Escalabilidad**: Fácil ejecutar todos los tests con un solo comando

---

## Unit Testing para Plugins (.NET Framework)

### 1. Creación del Proyecto de Tests

#### Paso 1: Crear el proyecto de tests

En Visual Studio:

1. Click derecho en la solución → **Add** → **New Project**
2. Buscar **"MSTest Test Project (.NET Framework)"**
3. Nombre: `{NombrePlugin}.Tests` (ej: `<Project>.SystemUser.Tests`)
4. Framework: **.NET Framework 4.7.1** (o la versión que uses para plugins)

> ⚠️ **IMPORTANTE**: Debe ser .NET Framework, NO .NET Core, ya que los plugins de Dynamics 365 no son compatibles con .NET Core.

#### Paso 2: Instalar Dependencias NuGet

Instala los siguientes paquetes NuGet en el proyecto de tests:

```powershell
Install-Package Microsoft.CrmSdk.CoreAssemblies
Install-Package Moq
```

**Descripción de dependencias:**

- `Microsoft.CrmSdk.CoreAssemblies`: Ensamblados del SDK de Dynamics 365
- `Moq`: Librería para crear mocks de interfaces y clases

#### Paso 3: Agregar Referencia al Proyecto del Plugin de negocio

Click derecho en **Dependencies** → **Add Project Reference** → Selecciona el proyecto del plugin

### 2. Estructura de un Test de Plugin

#### Ejemplo de Plugin a Testear

```csharp name=SystemUserPlugin.cs
using Microsoft.Xrm.Sdk;
using System;

namespace <Project>.SystemUser
{
    public class SystemUserPlugin : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = serviceFactory.CreateOrganizationService(context.UserId);

            if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
            {
                Entity target = (Entity)context.InputParameters["Target"];

                if (target.LogicalName != "systemuser")
                    return;

                // Lógica de negocio: Validar que el email no esté vacío
                if (target.Contains("internalemailaddress"))
                {
                    string email = target.GetAttributeValue<string>("internalemailaddress");
                    
                    if (string.IsNullOrWhiteSpace(email))
                    {
                        throw new InvalidPluginExecutionException("El email no puede estar vacío.");
                    }

                    // Validar formato de email
                    if (!email.Contains("@"))
                    {
                        throw new InvalidPluginExecutionException("El formato del email no es válido.");
                    }
                }
            }
        }
    }
}
```

#### Ejemplo de Test Unitario

```csharp name=SystemUserPluginTests.cs
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Moq;
using <Project>.SystemUser;
using System;

namespace <Project>.SystemUser.Tests
{
    [TestClass]
    public class SystemUserPluginTests
    {
        private Mock<IOrganizationService> _mockOrgService;
        private Mock<ITracingService> _mockTracingService;
        private Mock<IPluginExecutionContext> _mockContext;
        private Mock<IServiceProvider> _mockServiceProvider;
        private Mock<IOrganizationServiceFactory> _mockServiceFactory;
        private SystemUserPlugin _plugin;

        [TestInitialize]
        public void Initialize()
        {
            _mockOrgService = new Mock<IOrganizationService>();
            _mockTracingService = new Mock<ITracingService>();
            _mockContext = new Mock<IPluginExecutionContext>();
            _mockServiceProvider = new Mock<IServiceProvider>();
            _mockServiceFactory = new Mock<IOrganizationServiceFactory>();
            _plugin = new SystemUserPlugin();
        }

        #region Helper Methods

        private void SetupContextMocks(string messageName, string entityName, Guid userId, Entity targetEntity)
        {
            _mockContext.Setup(c => c.MessageName).Returns(messageName);
            _mockContext.Setup(c => c.PrimaryEntityName).Returns(entityName);
            _mockContext.Setup(c => c.UserId).Returns(userId);
            _mockContext.Setup(c => c.InputParameters).Returns(new ParameterCollection
            {
                { "Target", targetEntity }
            });
        }

        private void SetupServiceProvider()
        {
            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IPluginExecutionContext)))
                .Returns(_mockContext.Object);
            
            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(ITracingService)))
                .Returns(_mockTracingService.Object);
            
            _mockServiceProvider
                .Setup(sp => sp.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(_mockServiceFactory.Object);
            
            _mockServiceFactory
                .Setup(f => f.CreateOrganizationService(It.IsAny<Guid?>()))
                .Returns(_mockOrgService.Object);
        }

        #endregion

        #region Execute Method Tests

        [TestMethod]
        [TestCategory("SystemUser")]
        [Description("El plugin debe ejecutarse correctamente cuando el email es válido")]
        public void Execute_ValidEmail_ShouldNotThrowException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var targetEntity = new Entity("systemuser", userId)
            {
                ["internalemailaddress"] = "usuario@ejemplo.com"
            };

            SetupContextMocks("Create", "systemuser", userId, targetEntity);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockServiceProvider.Verify(x => x.GetService(typeof(IPluginExecutionContext)), Times.Once);
            _mockTracingService.Verify(x => x.Trace(It.IsAny<string>(), It.IsAny<object[]>()), Times.AtLeastOnce);
        }

        [TestMethod]
        [TestCategory("SystemUser")]
        [Description("El plugin debe lanzar excepción cuando el email está vacío")]
        [ExpectedException(typeof(InvalidPluginExecutionException))]
        public void Execute_EmptyEmail_ShouldThrowException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var targetEntity = new Entity("systemuser", userId)
            {
                ["internalemailaddress"] = ""
            };

            SetupContextMocks("Create", "systemuser", userId, targetEntity);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert is handled by ExpectedException attribute
        }

        [TestMethod]
        [TestCategory("SystemUser")]
        [Description("El plugin debe lanzar excepción cuando el formato del email es inválido")]
        public void Execute_InvalidEmailFormat_ShouldThrowException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var targetEntity = new Entity("systemuser", userId)
            {
                ["internalemailaddress"] = "emailsinformato"
            };

            SetupContextMocks("Create", "systemuser", userId, targetEntity);
            SetupServiceProvider();

            // Act & Assert
            try
            {
                _plugin.Execute(_mockServiceProvider.Object);
                Assert.Fail("Se esperaba una InvalidPluginExecutionException");
            }
            catch (InvalidPluginExecutionException ex)
            {
                Assert.AreEqual("El formato del email no es válido.", ex.Message);
            }
        }

        [TestMethod]
        [TestCategory("SystemUser")]
        [Description("El plugin debe ignorar entidades que no sean systemuser")]
        public void Execute_DifferentEntity_ShouldNotProcess()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var targetEntity = new Entity("account", Guid.NewGuid())
            {
                ["name"] = "Test Account"
            };

            SetupContextMocks("Create", "account", userId, targetEntity);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert - Verifica que no se realizaron operaciones sobre la entidad
            _mockOrgService.Verify(x => x.Update(It.IsAny<Entity>()), Times.Never);
            _mockOrgService.Verify(x => x.Create(It.IsAny<Entity>()), Times.Never);
        }

        [TestMethod]
        [TestCategory("SystemUser")]
        [Description("El plugin debe manejar correctamente cuando el campo email no existe")]
        public void Execute_EmailFieldNotPresent_ShouldNotThrowException()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var targetEntity = new Entity("systemuser", userId)
            {
                ["firstname"] = "John",
                ["lastname"] = "Doe"
            };

            SetupContextMocks("Update", "systemuser", userId, targetEntity);
            SetupServiceProvider();

            // Act
            _plugin.Execute(_mockServiceProvider.Object);

            // Assert
            _mockServiceProvider.Verify(x => x.GetService(typeof(IPluginExecutionContext)), Times.Once);
        }

        #endregion
    }
}
```

### 3. Ejecutar Tests en Visual Studio

#### Opción 1: Test Explorer

1. Ir a **Test** → **Test Explorer** (o `Ctrl + E, T`)
2. Click en **Run All** para ejecutar todos los tests
3. Los resultados aparecerán con indicadores ✅ verde (pasado) o ❌ rojo (fallado)

#### Opción 2: Línea de Comandos

```bash
# Ejecutar todos los tests de la solución
dotnet test

# Ejecutar tests de un proyecto específico
dotnet test <Project>.SystemUser.Tests
```

### 4. Análisis de Cobertura de Código

Visual Studio Enterprise incluye análisis de cobertura integrado:

1. Ir a **Test** → **Analyze Code Coverage for All Tests**
2. Se generará un reporte mostrando el % de cobertura
3. Puedes hacer click en los métodos para ver líneas no cubiertas

#### Herramientas Alternativas

Si no tienes Visual Studio Enterprise, puedes usar:

- **[Coverlet](https://github.com/coverlet-coverage/coverlet)**: Herramienta open-source para .NET
  ```bash
  dotnet add package coverlet.collector
  dotnet test --collect:"XPlat Code Coverage"
  ```

- **[ReportGenerator](https://github.com/danielpalme/ReportGenerator)**: Genera reportes HTML visuales
  ```bash
  dotnet tool install -g dotnet-reportgenerator-globaltool
  reportgenerator -reports:"coverage.cobertura.xml" -targetdir:"coveragereport"
  ```

---

## Unit Testing para Web Resources (JavaScript)

### 1. Configuración Inicial del Proyecto

#### Paso 1: Crear Proyecto JavaScript

1. En Visual Studio, click derecho en `WebResources` → **Add** → **New Project**
2. Seleccionar **"Blank Node.js Web Application"** o **"JavaScript Project"**
3. Nombre: `<Project>.WebResources`
4. Esto creará el archivo `package.json` y la estructura básica del proyecto.

Este proyecto contendrá **tanto los archivos JavaScript de negocio como los tests**.

#### Paso 2: Instalar Dependencias

```bash
# Instalar Vitest (framework de testing)
npm install --save-dev vitest

# Instalar xrm-mock (para mockear el contexto de Dynamics 365)
npm install --save-dev xrm-mock

# Instalar @vitest/ui (interfaz visual opcional)
npm install --save-dev @vitest/ui

# Instalar @vitest/coverage-v8 (para análisis de cobertura)
npm install --save-dev @vitest/coverage-v8
```

#### Paso 3: Configurar package.json

Añade los siguientes scripts en `package.json`:

```json name=package.json
{
  "name": "<Project>.webresources",
  "version": "1.0.0",
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage"
  },
  "devDependencies": {
    "vitest": "^3.2.4",
    "xrm-mock": "^3.6.2",
    "@vitest/ui": "^3.2.4",
    "@vitest/coverage-v8": "^3.2.4"
  }
}
```

#### Paso 4: Crear Configuración de Vitest

Crea el archivo `vitest.config.js` en la raíz del proyecto:

```javascript name=vitest.config.js
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['**/*.js'],
      exclude: ['**/*.test.js', 'node_modules/**', 'coverage/**']
    }
  },
   resolve: {
        alias: {
            // EXAMPLE - Define @src: go up 4 levels from /scripts to /WebResources and then enter /bshcs_/src/js
            '@src': path.resolve(__dirname, '../../../WebResources/<Project>.WebResources/bshcs_/src/js')
        }
   }
});
```

### 2. Estructura de un Test de Web Resource

#### Ejemplo de Web Resource a Testear

```javascript name=account.js
var <Project> = <Project> || {};
<Project>.Account = <Project>.Account || {};

/**
 * Función ejecutada al cargar el formulario de Account
 * @param {Object} executionContext - Contexto de ejecución de Dynamics 365
 */
<Project>.Account.onLoad = function (executionContext) {
    var formContext = executionContext.getFormContext();
    
    // Ocultar campo de descuento si el tipo de cuenta es "Competidor"
    var accountType = formContext.getAttribute("customertypecode");
    if (accountType && accountType.getValue() === 1) { // 1 = Competidor
        formContext.getControl("discountpercentage").setVisible(false);
    }
};

/**
 * Validar que el campo de teléfono tiene formato correcto
 * @param {Object} executionContext - Contexto de ejecución
 */
<Project>.Account.validatePhone = function (executionContext) {
    var formContext = executionContext.getFormContext();
    var phoneAttr = formContext.getAttribute("telephone1");
    
    if (phoneAttr) {
        var phone = phoneAttr.getValue();
        
        if (phone && phone.length < 9) {
            formContext.ui.setFormNotification(
                "El teléfono debe tener al menos 9 dígitos.",
                "ERROR",
                "phone_validation"
            );
            return false;
        } else {
            formContext.ui.clearFormNotification("phone_validation");
            return true;
        }
    }
};

/**
 * Hacer campo requerido dinámicamente
 * @param {Object} executionContext - Contexto de ejecución
 */
<Project>.Account.makeFieldRequired = function (executionContext) {
    var formContext = executionContext.getFormContext();
    var revenueAttr = formContext.getAttribute("revenue");
    
    if (revenueAttr) {
        revenueAttr.setRequiredLevel("required");
    }
};
```

#### Ejemplo de Test Unitario

```javascript name=account.test.js
import { describe, it, expect, beforeEach } from 'vitest';
import { XrmMockGenerator } from 'xrm-mock';

// Importar el archivo de negocio (ajusta la ruta según tu estructura)
import '../account.js';

describe('<Project>.Account - Form Logic Tests', () => {
    beforeEach(() => {
        // Re-inicializar el entorno de xrm-mock en cada test
        XrmMockGenerator.initialise();

        // Crear TODOS los atributos y controles necesarios para las pruebas
        // Atributo y control para tipo de cuenta
        XrmMockGenerator.Attribute.createOptionSet("customertypecode", 0);
        XrmMockGenerator.Control.createOptionSet({
            name: "discountpercentage",
            label: "Discount Percentage",
            visible: true
        });

        // Atributo para teléfono
        XrmMockGenerator.Attribute.createString("telephone1", "");

        // Atributo para revenue
        XrmMockGenerator.Attribute.createNumber("revenue", 0);
    });

    describe('onLoad', () => {
        it('debe ocultar el campo de descuento cuando el tipo de cuenta es Competidor', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("customertypecode").setValue(1); // 1 = Competidor

            // Act
            <Project>.Account.onLoad(context);

            // Assert
            const discountControl = formContext.getControl("discountpercentage");
            expect(discountControl.getVisible()).toBe(false);
        });

        it('no debe ocultar el campo de descuento cuando el tipo de cuenta NO es Competidor', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("customertypecode").setValue(2); // 2 = Cliente

            // Act
            <Project>.Account.onLoad(context);

            // Assert
            const discountControl = formContext.getControl("discountpercentage");
            expect(discountControl.getVisible()).toBe(true);
        });

        it('debe manejar correctamente cuando el atributo customertypecode es null', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("customertypecode").setValue(null);

            // Act & Assert - No debe lanzar excepción
            expect(() => <Project>.Account.onLoad(context)).not.toThrow();
        });
    });

    describe('validatePhone', () => {
        it('debe mostrar error cuando el teléfono tiene menos de 9 dígitos', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("telephone1").setValue("12345678");

            // Act
            const result = <Project>.Account.validatePhone(context);

            // Assert
            expect(result).toBe(false);
            // Verificar que se mostró la notificación
            const notifications = formContext.ui.formNotifications;
            expect(notifications).toBeDefined();
        });

        it('debe permitir teléfonos con 9 o más dígitos', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("telephone1").setValue("123456789");

            // Act
            const result = <Project>.Account.validatePhone(context);

            // Assert
            expect(result).toBe(true);
        });

        it('debe permitir teléfonos vacíos (campo opcional)', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            formContext.getAttribute("telephone1").setValue(null);

            // Act
            const result = <Project>.Account.validatePhone(context);

            // Assert
            expect(result).not.toBe(false);
        });

        it('debe limpiar notificaciones cuando el teléfono es válido', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            
            // Primero establecer un teléfono inválido para crear la notificación
            formContext.getAttribute("telephone1").setValue("123");
            <Project>.Account.validatePhone(context);

            // Ahora corregir el teléfono
            formContext.getAttribute("telephone1").setValue("987654321");

            // Act
            const result = <Project>.Account.validatePhone(context);

            // Assert
            expect(result).toBe(true);
        });
    });

    describe('makeFieldRequired', () => {
        it('debe hacer el campo revenue requerido', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();

            // Act
            <Project>.Account.makeFieldRequired(context);

            // Assert
            const revenueAttr = formContext.getAttribute("revenue");
            expect(revenueAttr.getRequiredLevel()).toBe("required");
        });

        it('debe manejar correctamente cuando el atributo revenue no existe', () => {
            // Arrange
            const context = XrmMockGenerator.getEventContext();
            const formContext = context.getFormContext();
            
            // Simular que el atributo no existe
            formContext.getAttribute = (name) => {
                if (name === "revenue") return null;
                return XrmMockGenerator.getFormContext().getAttribute(name);
            };

            // Act & Assert - No debe lanzar excepción
            expect(() => <Project>.Account.makeFieldRequired(context)).not.toThrow();
        });
    });
});
```

### 3. Convenciones de Nomenclatura

> ⚠️ **IMPORTANTE**: Los tests en JavaScript **DEBEN** nombrarse siguiendo el patrón:

```
{nombre_archivo_negocio}.test.js
```

**Ejemplos:**
- `account.js` → `account.test.js`
- `systemuser.js` → `systemuser.test.js`
- `opportunity.formlogic.js` → `opportunity.formlogic.test.js`

### 4. Ejecutar Tests

#### Opción 1: Ejecutar todos los tests (Terminal)

```bash
npm run test
```

**Salida esperada:**

```
✓ <Project>.Account.onLoad > debe ocultar el campo de descuento cuando el tipo de cuenta es Competidor
✓ <Project>.Account.onLoad > no debe ocultar el campo de descuento cuando el tipo de cuenta NO es Competidor
✓ <Project>.Account.validatePhone > debe mostrar error cuando el teléfono tiene menos de 9 dígitos
✓ <Project>.Account.validatePhone > debe permitir teléfonos con 9 o más dígitos
✓ <Project>.Account.validatePhone > debe permitir teléfonos vacíos (campo opcional)
✓ <Project>.Account.makeFieldRequired > debe hacer el campo revenue requerido

Test Files  1 passed (1)
     Tests  6 passed (6)
  Start at  14:32:15
  Duration  423ms
```

#### Opción 2: Ejecutar tests en modo watch (desarrollo continuo)

```bash
npm run test:run
```

Los tests se ejecutarán automáticamente cada vez que guardes cambios.

#### Opción 3: Interfaz visual

```bash
npm run test:ui
```

Esto abrirá una interfaz web en `http://localhost:51204` donde puedes:
- Ver todos los tests
- Filtrar por estado (pasado/fallado)
- Ver el código de cada test
- Ver errores detallados

### 5. Análisis de Cobertura

```bash
npm run coverage
```

**Salida esperada:**

```
 % Coverage report from v8
--------------------|---------|----------|---------|---------|-------------------
File                | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
--------------------|---------|----------|---------|---------|-------------------
All files           |   92.85 |    87.50 |     100 |   92.85 |
 account.js         |   92.85 |    87.50 |     100 |   92.85 | 15-17
--------------------|---------|----------|---------|---------|-------------------
```

El reporte HTML se generará en `coverage/index.html` para visualización detallada.

---

## Cobertura de Código (Code Coverage)

### ¿Qué es Code Coverage?

El **code coverage** (cobertura de código) mide el porcentaje de código que es ejecutado por tus tests. Existen diferentes métricas:

- **Statement Coverage**: % de líneas ejecutadas
- **Branch Coverage**: % de ramas condicionales (if/else) ejecutadas
- **Function Coverage**: % de funciones llamadas
- **Line Coverage**: % de líneas no vacías ejecutadas

### Estándar de Calidad

> 🎯 **Objetivo mínimo: 80% de cobertura de código**

### Interpretar Resultados

#### ✅ Buena Cobertura (>80%)

```
--------------------|---------|----------|---------|---------|
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
account.js          |   95.83 |    91.67 |     100 |   95.83 |
systemuser.js       |   88.24 |    85.00 |     100 |   88.24 |
--------------------|---------|----------|---------|---------|
```

#### ⚠️ Cobertura Insuficiente (<80%)

```
--------------------|---------|----------|---------|---------|
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
account.js          |   65.22 |    50.00 |   75.00 |   65.22 |
--------------------|---------|----------|---------|---------|
```

**Acción requerida**: Añadir más tests para cubrir los casos faltantes.

### Visualizar Código No Cubierto

#### Visual Studio (.NET)

1. Después de ejecutar el análisis de cobertura
2. En el Code Coverage Results, hacer doble click en un archivo
3. Las líneas **rojas** no están cubiertas
4. Las líneas **azules** están cubiertas

#### JavaScript (HTML Report)

1. Abrir `coverage/index.html` en un navegador
2. Click en un archivo
3. Las líneas **rojas** no están cubiertas
4. Las líneas **verdes** están cubiertas

---

## Buenas Prácticas

### 1. Patrón AAA (Arrange-Act-Assert)

Estructura tus tests siguiendo este patrón:

```csharp
[TestMethod]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange - Preparar datos y mocks
    var target = new Entity("account");
    var mockService = CreateMockService();

    // Act - Ejecutar la acción a testear
    var result = plugin.Execute(mockService.Object);

    // Assert - Verificar el resultado
    Assert.IsNotNull(result);
    Assert.AreEqual("Expected Value", result.Value);
}
```

### 2. Nomenclatura de Tests

#### Patrón recomendado:

```
{MethodName}_{Scenario}_{ExpectedResult}
```

#### Ejemplos:

**C#:**
```csharp
Execute_ValidEmail_ShouldNotThrowException()
Execute_EmptyEmail_ShouldThrowInvalidPluginExecutionException()
CalculateDiscount_PremiumCustomer_ShouldReturn20Percent()
```

**JavaScript:**
```javascript
it('debe ocultar el campo cuando el tipo es Competidor', ...)
it('debe mostrar error cuando el email es inválido', ...)
it('debe calcular el descuento correctamente para clientes premium', ...)
```

### 3. Un Test, Un Concepto

Cada test debe validar **UNA SOLA cosa**:

❌ **Incorrecto:**
```csharp
[TestMethod]
public void Execute_MultipleValidations()
{
    // Valida email, teléfono y nombre al mismo tiempo
    Assert.IsNotNull(email);
    Assert.IsTrue(phone.Length > 9);
    Assert.IsFalse(string.IsNullOrEmpty(name));
}
```

✅ **Correcto:**
```csharp
[TestMethod]
public void Execute_ValidEmail_ShouldNotBeNull() { ... }

[TestMethod]
public void Execute_ValidPhone_ShouldHaveMinimumLength() { ... }

[TestMethod]
public void Execute_ValidName_ShouldNotBeEmpty() { ... }
```

### 4. Tests Independientes

Los tests **NO deben depender** unos de otros:

- No usar variables globales compartidas
- No asumir orden de ejecución
- Usar `beforeEach()` (JS) o `[TestInitialize]` (C#) para inicializar

#### Buena Práctica: Inicialización Centralizada en JavaScript

Para tests de JavaScript con xrm-mock, **centraliza la creación de todos los atributos y controles** en el `beforeEach`:

✅ **Correcto - Inicialización centralizada:**
```javascript
describe('Account Form Tests', () => {
    beforeEach(() => {
        XrmMockGenerator.initialise();
        
        // Crear TODOS los atributos necesarios una sola vez
        XrmMockGenerator.Attribute.createString("name", "");
        XrmMockGenerator.Attribute.createOptionSet("accountcategory", null);
        XrmMockGenerator.Attribute.createNumber("revenue", 0);
        // ... todos los campos del formulario
    });

    it('test 1', () => {
        const context = XrmMockGenerator.getEventContext();
        // Solo modifica valores, no crea atributos
        context.getFormContext().getAttribute("name").setValue("Test");
    });
});
```

❌ **Incorrecto - Creación repetitiva:**
```javascript
describe('Account Form Tests', () => {
    it('test 1', () => {
        XrmMockGenerator.initialise();
        // ❌ Crear atributos dentro de cada test
        XrmMockGenerator.Attribute.createString("name", "");
        const context = XrmMockGenerator.getEventContext();
    });
    
    it('test 2', () => {
        XrmMockGenerator.initialise();
        // ❌ Repetir la creación de atributos
        XrmMockGenerator.Attribute.createString("name", "");
        const context = XrmMockGenerator.getEventContext();
    });
});
```

**Ventajas del enfoque centralizado:**
- 🚀 Menos código repetitivo (DRY principle)
- 🧹 Tests más limpios y legibles
- 🔧 Más fácil de mantener
- 🎯 Tests enfocados en el comportamiento, no en la configuración

### 6. Datos de Prueba Realistas

Usa datos que representen casos reales:

```javascript
// ❌ Malo
formContext.getAttribute("name").setValue("Test");

// ✅ Bueno
formContext.getAttribute("name").setValue("Acme Corporation S.L.");
formContext.getAttribute("telephone1").setValue("+34 912 345 678");
```

### 7. Testear Casos Edge

No solo pruebes el "happy path", incluye:

- ✅ Valores nulos o undefined
- ✅ Strings vacías
- ✅ Números negativos o cero
- ✅ Arrays vacíos
- ✅ Fechas inválidas
- ✅ Permisos insuficientes

### 8. Uso de Categorías/Tags

#### C#:
```csharp
[TestMethod]
[TestCategory("Plugin")]
[TestCategory("Account")]
[TestCategory("Integration")]
public void Execute_CreateAccount_ShouldSetDefaults() { ... }
```

Ejecutar solo tests de una categoría:
```bash
dotnet test --filter TestCategory=Plugin
```

#### JavaScript:
```javascript
describe.only('Tests prioritarios', () => { ... });
describe.skip('Tests temporalmente deshabilitados', () => { ... });
```

### 9. Comentarios y Descripciones

Añade descripciones claras a tus tests:

**C#:**
```csharp
[TestMethod]
[Description("Verifica que el plugin establece el campo 'status' a 'Active' cuando se crea una cuenta nueva")]
public void Execute_NewAccount_ShouldSetStatusToActive() { ... }
```

**JavaScript:**
```javascript
it('debe establecer el campo "status" a "Active" cuando se crea una cuenta nueva', () => { ... });
```

---

## Troubleshooting

### Problemas Comunes en .NET

#### 1. Error: "Could not load file or assembly"

**Causa**: Versiones incompatibles de Microsoft.CrmSdk.CoreAssemblies

**Solución**:
```bash
# Asegúrate de que todos los proyectos usan la misma versión
Update-Package Microsoft.CrmSdk.CoreAssemblies -ProjectName <Project>.Account
Update-Package Microsoft.CrmSdk.CoreAssemblies -ProjectName <Project>.Account.Tests
```

#### 2. Error: "The given key was not present in the dictionary"

**Causa**: Falta agregar parámetros al InputParameters mock

**Solución**:
```csharp
mockContext.Setup(c => c.InputParameters).Returns(new ParameterCollection
{
    { "Target", targetEntity },
    { "PreEntityImage", preImage },  // Añadir imágenes si son necesarias
    { "PostEntityImage", postImage }
});
```

#### 3. Los tests pasan en local pero fallan en el servidor

**Causa**: Diferencias de cultura/timezone

**Solución**:
```csharp
[TestInitialize]
public void TestInit()
{
    Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
    Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");
}
```

### Problemas Comunes en JavaScript

#### 1. Error: "Cannot find module"

**Causa**: Ruta de importación incorrecta

**Solución**:
```javascript
// Usar rutas relativas correctas
import '../account.js';  // Si el test está en la misma carpeta
import '../../WebResources/account.js';  // Si está en carpeta separada
```

#### 2. Coverage muestra 0%

**Causa**: Configuración incorrecta de rutas en `vitest.config.js`

**Solución**:
```javascript
coverage: {
    include: ['**/*.js'],
    exclude: [
        '**/*.test.js',
        'node_modules/**',
        'coverage/**',
        'vitest.config.js'
    ]
}
```

#### 3. Error: "Xrm is not defined"

**Causa**: No se está usando xrm-mock correctamente

**Solución**:
```javascript
import { XrmMockGenerator } from 'xrm-mock';

beforeEach(() => {
    XrmMockGenerator.initialise();  // ¡No olvidar inicializar!
    formContext = XrmMockGenerator.getFormContext();
});
```

#### 4. Tests muy lentos

**Causa**: Re-importación innecesaria en cada test

**Solución**:
```javascript
// Importar una sola vez al inicio del archivo
import '../account.js';

// No importar dentro de los tests
describe('Suite', () => {
    it('test', () => {
        // ❌ No hacer: import '../account.js';
    });
});
```

---

## Integración CI/CD

Aunque la configuración detallada de CI/CD está fuera del alcance de esta guía, es importante saber que **los tests unitarios pueden y deben ejecutarse automáticamente** en tus pipelines de integración continua.

### Azure DevOps

Ejemplo de paso en `azure-pipelines.yml`:

```yaml
# Tests de .NET
- task: VSTest@2
  displayName: 'Run .NET Unit Tests'
  inputs:
    testAssemblyVer2: '**\*.Tests.dll'
    codeCoverageEnabled: true
    
# Tests de JavaScript
- script: |
    cd Dataverse/WebResources/<Project>.WebResources
    npm install
    npm run test
    npm run coverage
  displayName: 'Run JavaScript Unit Tests'
```

### GitHub Actions

Ejemplo de workflow `.github/workflows/test.yml`:

```yaml
name: Run Unit Tests

on: [push, pull_request]

jobs:
  test-dotnet:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '6.0.x'
      - name: Run tests
        run: dotnet test --configuration Release
        
  test-javascript:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
        working-directory: ./Dataverse/WebResources/<Project>.WebResources
      - name: Run tests
        run: npm test
        working-directory: ./Dataverse/WebResources/<Project>.WebResources
```

### Beneficios de CI/CD con Tests

- ✅ **Detección temprana**: Los bugs se detectan antes de merge
- ✅ **Quality gates**: Bloquea PRs si los tests fallan o la cobertura es baja
- ✅ **Automatización**: No depende de que alguien recuerde ejecutar tests
- ✅ **Historial**: Tracking de cobertura a lo largo del tiempo

---

## Recursos Adicionales

### Documentación Oficial

- **MSTest**: [Microsoft Docs - Unit testing with MSTest](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-mstest)
- **Moq**: [Moq GitHub Repository](https://github.com/moq/moq4)
- **Vitest**: [Vitest Documentation](https://vitest.dev/)
- **xrm-mock**: [xrm-mock GitHub Repository](https://github.com/davidjbclark/xrm-mock)

### Herramientas Útiles

- **Visual Studio Test Explorer**: Explorador de tests integrado
- **ReSharper**: Extensión de Visual Studio con mejoras para testing
- **Wallaby.js**: Ejecuta tests de JavaScript mientras escribes código
- **SonarQube**: Análisis de calidad de código y cobertura

---

## Resumen - Checklist de Implementación

### Para Plugins (.NET Framework)

- [ ] Crear proyecto `{NombrePlugin}.Tests` con MSTest
- [ ] Instalar paquetes: `MSTest.TestFramework`, `MSTest.TestAdapter`, `CoreAssemblies`, `Moq`
- [ ] Crear mocks de `IServiceProvider`, `IOrganizationService`, `IPluginExecutionContext`
- [ ] Escribir tests siguiendo patrón AAA
- [ ] Alcanzar mínimo 80% de cobertura
- [ ] Ejecutar tests desde Test Explorer o CLI
- [ ] Analizar cobertura con Visual Studio o Coverlet

### Para Web Resources (JavaScript)

- [ ] Crear proyecto JavaScript unificado `<Project>.WebResources`
- [ ] Instalar: `vitest`, `xrm-mock`, `@vitest/ui`, `@vitest/coverage-v8`
- [ ] Crear `vitest.config.js`
- [ ] Añadir scripts en `package.json`: `test`, `test:ui`, `coverage`
- [ ] Nombrar tests como `{archivo}.test.js`
- [ ] Usar `XrmMockGenerator` para mockear formContext
- [ ] Alcanzar mínimo 80% de cobertura
- [ ] Ejecutar `npm run test` y `npm run coverage`

---

## Conclusión

La implementación de **unit testing** en proyectos de Dynamics 365 y Power Platform es fundamental para garantizar la calidad, mantenibilidad y confiabilidad del código. Siguiendo las prácticas establecidas en esta guía, tu equipo podrá:

- ✅ Detectar bugs antes de que lleguen a producción
- ✅ Refactorizar código con confianza
- ✅ Documentar el comportamiento esperado del sistema
- ✅ Cumplir con estándares de calidad (80% cobertura mínima)
- ✅ Integrar tests en pipelines CI/CD para automatización completa

**Recuerda**: El tiempo invertido en escribir tests se recupera con creces en tiempo ahorrado de debugging y hotfixes en producción.

---

**Autor**: Francisco Antonio Fernández Coloma  
**Fecha**: Febrero 2026  
**Versión**: 1.0  
**Licencia**: Uso interno - Todos los derechos reservados