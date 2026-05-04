# C# Test Patterns for Dynamics 365 Plugins

## Complete Test Class Skeleton (Mandatory)

Every D365 plugin test class MUST wire the complete service provider chain:

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Contoso.Plugins.Tests
{
    [TestClass]
    public class MyPluginTests
    {
        private Mock<IOrganizationService> _mockOrgService;
        private Mock<ITracingService> _mockTracingService;
        private Mock<IPluginExecutionContext> _mockContext;
        private Mock<IServiceProvider> _mockServiceProvider;
        private Mock<IOrganizationServiceFactory> _mockServiceFactory;
        private MyPlugin _plugin;
        private Guid _targetId;
        private Guid _relatedEntityId;

        [TestInitialize]
        public void Initialize()
        {
            _mockOrgService = new Mock<IOrganizationService>();
            _mockTracingService = new Mock<ITracingService>();
            _mockContext = new Mock<IPluginExecutionContext>();
            _mockServiceProvider = new Mock<IServiceProvider>();
            _mockServiceFactory = new Mock<IOrganizationServiceFactory>();
            _plugin = new MyPlugin();
            _targetId = Guid.NewGuid();
            _relatedEntityId = Guid.NewGuid();
            SetupServiceProvider();
        }

        [TestCleanup]
        public void Cleanup() { /* Dispose HttpListeners, streams, etc. */ }

        #region Service Provider Setup
        private void SetupServiceProvider()
        {
            _mockServiceProvider.Setup(x => x.GetService(typeof(ITracingService))).Returns(_mockTracingService.Object);
            _mockServiceProvider.Setup(x => x.GetService(typeof(IPluginExecutionContext))).Returns(_mockContext.Object);
            _mockServiceProvider.Setup(x => x.GetService(typeof(IOrganizationServiceFactory))).Returns(_mockServiceFactory.Object);
            _mockServiceFactory.Setup(x => x.CreateOrganizationService(It.IsAny<Guid?>())).Returns(_mockOrgService.Object);
        }
        #endregion
    }
}
```

---

## Test Organization

```csharp
#region Execute - Early Return Tests
#endregion
#region Execute - Happy Path Tests
#endregion
#region Execute - Edge Cases
#endregion
#region Execute - Exception Handling
#endregion
#region Helper Setup Methods
#endregion
```

---

## Context Setup Helpers

```csharp
private void SetupContext(Entity target)
{
    _mockContext.Setup(x => x.InputParameters)
        .Returns(new ParameterCollection { { "Target", target } });
    _mockContext.Setup(x => x.UserId).Returns(Guid.NewGuid());
}

// Pre/Post Images
var preImage = new Entity("account", _targetId);
preImage["statecode"] = new OptionSetValue(0);
_mockContext.Setup(c => c.PreEntityImages)
    .Returns(new EntityImageCollection { { "PreImage", preImage } });

// Context properties
_mockContext.Setup(c => c.MessageName).Returns("Create");
_mockContext.Setup(c => c.Stage).Returns(40); // PostOperation
_mockContext.Setup(c => c.PrimaryEntityName).Returns("incident");
_mockContext.Setup(c => c.PrimaryEntityId).Returns(_targetId);
_mockContext.Setup(c => c.Depth).Returns(1);
_mockContext.Setup(c => c.Mode).Returns(0); // Synchronous
```

---

## Early Return / Guard Clause Tests

```csharp
[TestMethod]
public void Execute_NoTargetInInputParameters_ReturnsEarly()
{
    _mockContext.Setup(x => x.InputParameters).Returns(new ParameterCollection());
    _mockContext.Setup(x => x.UserId).Returns(Guid.NewGuid());
    _plugin.Execute(_mockServiceProvider.Object);
    _mockOrgService.Verify(x => x.Retrieve(It.IsAny<string>(), It.IsAny<Guid>(), It.IsAny<ColumnSet>()), Times.Never);
}

[TestMethod]
public void Execute_TargetIsWrongEntityType_ReturnsEarly()
{
    var target = new Entity("account", Guid.NewGuid()); // Plugin expects "incident"
    _mockContext.Setup(x => x.InputParameters).Returns(new ParameterCollection { { "Target", target } });
    _mockContext.Setup(x => x.UserId).Returns(Guid.NewGuid());
    _plugin.Execute(_mockServiceProvider.Object);
    _mockOrgService.Verify(x => x.Retrieve(It.IsAny<string>(), It.IsAny<Guid>(), It.IsAny<ColumnSet>()), Times.Never);
}
```

---

## Mocking Retrieve / RetrieveMultiple

```csharp
// Single Retrieve
private void SetupRetrieveEntity(string logicalName, Guid id, Entity entity)
{
    _mockOrgService.Setup(x => x.Retrieve(logicalName, id, It.IsAny<ColumnSet>())).Returns(entity);
}

// Sequential RetrieveMultiple (ordered returns)
private void SetupRetrieveMultipleSequence(EntityCollection[] results)
{
    var setup = _mockOrgService.SetupSequence(x => x.RetrieveMultiple(It.IsAny<QueryExpression>()));
    foreach (var result in results) setup = setup.Returns(result);
}

// Dictionary-Based Query Routing (by entity name)
private void SetupRetrieveMultipleByEntity(Dictionary<string, Queue<EntityCollection>> resultsByEntity)
{
    _mockOrgService.Setup(x => x.RetrieveMultiple(It.IsAny<QueryBase>()))
        .Returns((QueryBase qb) =>
        {
            var qe = (QueryExpression)qb;
            if (resultsByEntity.ContainsKey(qe.EntityName) && resultsByEntity[qe.EntityName].Count > 0)
                return resultsByEntity[qe.EntityName].Dequeue();
            return new EntityCollection();
        });
}

// Usage:
SetupRetrieveMultipleByEntity(new Dictionary<string, Queue<EntityCollection>>
{
    { "prefix_country", new Queue<EntityCollection>(new[] {
        new EntityCollection(new List<Entity> { countryResult })
    })},
    { "msdyn_incidenttype", new Queue<EntityCollection>(new[] {
        new EntityCollection(),
        new EntityCollection(new List<Entity> { fallbackResult })
    })}
});
```

---

## Exception Testing

```csharp
// Simple: attribute-based
[TestMethod]
[ExpectedException(typeof(InvalidPluginExecutionException))]
public void Execute_MissingRequiredField_ThrowsException()
{
    var target = new Entity("incident", _targetId);
    SetupContext(target);
    _plugin.Execute(_mockServiceProvider.Object);
}

// Inspect message:
[TestMethod]
public void Execute_UnexpectedException_WrapsWithContext()
{
    var target = new Entity("incident", _targetId);
    SetupContext(target);
    _mockOrgService.Setup(x => x.Retrieve("incident", _targetId, It.IsAny<ColumnSet>()))
        .Throws(new ArgumentException("Simulated failure"));
    var ex = Assert.ThrowsException<InvalidPluginExecutionException>(
        () => _plugin.Execute(_mockServiceProvider.Object));
    StringAssert.Contains(ex.Message, "Simulated failure");
}
```

---

## Verifying Service Calls

```csharp
// Create with attributes
_mockOrgService.Verify(x => x.Create(It.Is<Entity>(e =>
    e.LogicalName == "msdyn_incidenttype" && e.Contains("msdyn_name"))), Times.Once());

// Update with correct value
_mockOrgService.Verify(s => s.Update(It.Is<Entity>(e =>
    e.LogicalName == "account" &&
    e.GetAttributeValue<Money>("revenue").Value == 150000m)), Times.Once);

// Never called (early return)
_mockOrgService.Verify(s => s.Update(It.IsAny<Entity>()), Times.Never);

// Associate (N:N)
_mockOrgService.Verify(x => x.Associate(
    It.Is<string>(s => s == "msdyn_incidenttype"),
    It.Is<Guid>(g => g == newItGuid),
    It.IsAny<Relationship>(),
    It.IsAny<EntityReferenceCollection>()), Times.Once());

// RetrieveMultiple query shape
_mockOrgService.Verify(s => s.RetrieveMultiple(It.Is<QueryExpression>(q =>
    q.EntityName == "contact" &&
    q.Criteria.Conditions.Any(c =>
        c.AttributeName == "parentcustomerid" &&
        c.Operator == ConditionOperator.Equal))), Times.Once);
```

---

## Factory Helper Methods

```csharp
#region Helper Setup Methods
private Entity CreateCaseEntity()
{
    var caseEntity = new Entity("incident", _targetId);
    caseEntity["prefix_customerassetid"] = new EntityReference("msdyn_customerasset", _relatedEntityId);
    caseEntity["msdyn_functionallocation"] = new EntityReference("msdyn_functionallocation", Guid.NewGuid());
    return caseEntity;
}

private Entity CreateProductEntity(bool hasEnr)
{
    var product = new Entity("product", Guid.NewGuid());
    product["name"] = hasEnr ? "SMD6TCX00E/17" : "GenericProduct";
    product["productnumber"] = hasEnr ? "SMD6TCX00E/17" : "GENERIC";
    product["prefix_brandid"] = new EntityReference("prefix_brand", Guid.NewGuid());
    return product;
}
#endregion
```

---

## Environment Variables Testing

```csharp
private Entity CreateEnvVarDefinition()
{
    var def = new Entity("environmentvariabledefinition", Guid.NewGuid());
    def["environmentvariabledefinitionid"] = def.Id;
    return def;
}

private Entity CreateEnvVarValue(string value)
{
    var val = new Entity("environmentvariablevalue", Guid.NewGuid());
    val["value"] = value;
    return val;
}
```

---

## Mock HTTP Server (External API Testing)

```csharp
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

private HttpListener _httpListener;

[TestCleanup]
public void Cleanup()
{
    if (_httpListener != null)
    {
        try { _httpListener.Stop(); } catch { }
        try { _httpListener.Close(); } catch { }
        _httpListener = null;
    }
}

private string StartMockServer(string responseJson)
{
    var tcpListener = new TcpListener(IPAddress.Loopback, 0);
    tcpListener.Start();
    int port = ((IPEndPoint)tcpListener.LocalEndpoint).Port;
    tcpListener.Stop();

    string prefix = $"http://localhost:{port}/";
    _httpListener = new HttpListener();
    _httpListener.Prefixes.Add(prefix);
    _httpListener.Start();

    ThreadPool.QueueUserWorkItem(_ =>
    {
        try
        {
            while (_httpListener.IsListening)
            {
                var ctx = _httpListener.GetContext();
                var body = Encoding.UTF8.GetBytes(responseJson);
                ctx.Response.ContentType = "application/json";
                ctx.Response.ContentLength64 = body.Length;
                ctx.Response.StatusCode = 200;
                ctx.Response.OutputStream.Write(body, 0, body.Length);
                ctx.Response.Close();
            }
        }
        catch (HttpListenerException) { }
        catch (ObjectDisposedException) { }
    });
    return $"http://localhost:{port}";
}
```

---

## Data-Driven Tests

```csharp
[TestMethod]
[DataRow(0, true)]   // Active → process
[DataRow(2, false)]  // Inactive → skip
public void Execute_DifferentStates_ProcessesAccordingly(int statusValue, bool shouldProcess)
{
    var target = new Entity("account", _targetId);
    target["statecode"] = new OptionSetValue(statusValue);
    SetupContext(target);
    _plugin.Execute(_mockServiceProvider.Object);

    if (shouldProcess)
        _mockOrgService.Verify(s => s.Update(It.IsAny<Entity>()), Times.Once);
    else
        _mockOrgService.Verify(s => s.Update(It.IsAny<Entity>()), Times.Never);
}
```

---

## Naming Convention

Pattern: `Execute_{Scenario}_{ExpectedResult}` or `When{Condition}_Then{Result}`

---

## Checklist

- [ ] Full IServiceProvider chain in `[TestInitialize]`
- [ ] Early return tests for invalid inputs
- [ ] Happy path test for primary scenario
- [ ] Exception tests for missing data
- [ ] Verify service calls with correct parameters
- [ ] `SetupSequence` for multiple RetrieveMultiple calls
- [ ] `[TestCleanup]` for HttpListener / disposable resources
- [ ] Factory helpers for entity creation
- [ ] Exception wrapping tests (→ InvalidPluginExecutionException)
