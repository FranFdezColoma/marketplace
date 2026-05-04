---
name: unit-test-builder
description: Generate unit tests for Dynamics 365 plugins (C#/MSTest/Moq) and JavaScript web resources (Vitest/xrm-mock). Follows AAA pattern, creates comprehensive test coverage for D365 code. Use when the user needs to create or improve unit tests.
---

# Unit Test Builder for D365/Power Platform

## C# Plugin Unit Tests

### Technology Stack

| Package | Version |
|---------|---------|
| Microsoft.CrmSdk.CoreAssemblies | 9.0.2.x |
| MSTest.TestFramework | 2.2.10 |
| MSTest.TestAdapter | 2.2.10 |
| Microsoft.NET.Test.Sdk | 17.x |
| Moq | 4.20.72 |
| Castle.Core | 5.1.1 |

### Naming Convention

```
When[Condition]_Then[ExpectedResult]
Execute_[Scenario]_[ExpectedBehavior]
```

### Required Test Categories

1. **Happy path** — valid input produces expected output
2. **Validation failures** — missing/invalid input throws `InvalidPluginExecutionException`
3. **Edge cases** — null values, empty collections, boundaries
4. **Context validation** — wrong message, wrong entity, depth > threshold
5. **Service interactions** — verify Create/Update/Retrieve called with correct parameters

### Mock Setup (Mandatory Chain)

Every test class MUST wire: `IServiceProvider` → `IPluginExecutionContext` + `ITracingService` + `IOrganizationServiceFactory` → `IOrganizationService`.

See `./reference/csharp-test-patterns.md` for complete skeleton, helper methods, Sequential/Dictionary-based query routing, and HttpListener mock server.

### CLI

```powershell
dotnet test [TestProject].csproj --verbosity normal
dotnet-coverage collect -f cobertura -o coverage.xml dotnet test
```

---

## JavaScript Web Resource Unit Tests

### Technology Stack

| Package | Version |
|---------|---------|
| vitest | ^3.2.4 |
| xrm-mock | ^3.6.2 |
| jsdom | ^28.1.0 |
| @vitest/coverage-v8 | ^3.2.4 |
| @vitest/ui | ^3.2.4 |

### package.json

```json
{
  "name": "paramount.webresources.tests",
  "version": "1.0.0",
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  },
  "devDependencies": {
    "@types/jsdom": "^28.0.0",
    "@vitest/coverage-v8": "^3.2.4",
    "@vitest/ui": "^3.2.4",
    "eslint": "^9.39.2",
    "jsdom": "^28.1.0",
    "pcf-scripts": "^1",
    "vitest": "^3.2.4",
    "xrm-mock": "^3.6.2"
  }
}
```

### vitest.config.js

```javascript
import { defineConfig } from 'vitest/config';
export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**/*.js'],
      exclude: ['**/*.test.js', '**/*.spec.js']
    }
  }
});
```

### Source File Testability Pattern

```javascript
var Contoso = Contoso || {};
Contoso.Account = Contoso.Account || {};
Contoso.Account.OnLoad = function(executionContext) { /* ... */ };

// ── Exports (for unit testing) ──────────────────────────────────────────────
if (typeof module !== "undefined" && module.exports) {
  module.exports = { OnLoad: Contoso.Account.OnLoad };
}
```

### Key Patterns

- Import: `import { onLoad } from "./AccountFormCC.js";`
- Setup: `XrmMockGenerator.initialise()` in `beforeEach`
- Cleanup: `afterEach(() => vi.clearAllMocks())`
- Async flush: `await new Promise(resolve => setTimeout(resolve, 0))`
- Lookups are **arrays**: `[{ id, entityType, name }]`
- Mock `global.Xrm.WebApi`, `global.Xrm.Navigation`
- Error handling: `vi.spyOn(console, "error").mockImplementation(() => {})`
- Save prevention: mock `eventArgs.preventDefault`

See `./reference/js-test-patterns.md` for comprehensive beforeEach setup, section organization, and all testing patterns.

### CLI

```powershell
npm run test:run
npm run test:coverage
npm run test:ui
```
