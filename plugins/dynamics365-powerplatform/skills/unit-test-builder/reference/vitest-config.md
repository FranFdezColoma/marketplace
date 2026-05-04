# Vitest Configuration Reference

## vitest.config.js

Standard configuration for D365 web resource testing:

```javascript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "jsdom",
    globals: false,
    setupFiles: [],
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "html"],
      include: ["src/**/*.js"],
      exclude: ["node_modules", "test/**"],
    },
  },
});
```

## Key Configuration Options

| Option | Value | Purpose |
|--------|-------|---------|
| `environment` | `"jsdom"` | Simulates browser DOM for Xrm form scripts |
| `globals` | `false` | Requires explicit import of `describe`, `it`, `expect` |
| `setupFiles` | `[]` | Add global setup if needed (e.g., Xrm global initialization) |
| `coverage.provider` | `"v8"` | V8 coverage engine (fast, accurate) |

## package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

## Required Dependencies

```json
{
  "devDependencies": {
    "@types/jsdom": "^28.0.0",
    "@vitest/coverage-v8": "^3.2.4",
    "@vitest/ui": "^3.2.4",
    "jsdom": "^28.1.0",
    "vitest": "^3.2.4",
    "xrm-mock": "^3.6.2"
  }
}
```

## Usage Notes

- **No globals**: Always import `{ describe, it, expect, beforeEach, afterEach, vi }` from `"vitest"`
- **JSDOM environment**: Required for `document`, `window`, and DOM APIs used by xrm-mock
- **Coverage threshold**: Configure as needed per project maturity (recommend 80%+ for critical logic)
- **xrm-mock**: Provides `XrmMockGenerator` for simulating Dynamics 365 form context
