# JavaScript Test Patterns for D365 Web Resources

## Configuration

```javascript
// vitest.config.js
import { defineConfig } from "vitest/config";
export default defineConfig({
  test: {
    environment: "jsdom",
    globals: true,
    coverage: { provider: "v8", reporter: ["text", "html", "lcov"], include: ["src/**/*.js"], exclude: ["**/*.test.js"] }
  }
});
```

## Source File Pattern (module.exports)

```javascript
var Contoso = Contoso || {};
Contoso.Account = Contoso.Account || {};
Contoso.Account.onLoad = function (executionContext) { /* ... */ };
Contoso.Account.onSave = function (executionContext) { /* ... */ };

// ── Exports (for unit testing) ───────────────────────────────────────────
if (typeof module !== "undefined" && module.exports) {
  module.exports = { onLoad: Contoso.Account.onLoad, onSave: Contoso.Account.onSave };
}
```

---

## Test File Import

```javascript
import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { XrmMockGenerator } from "xrm-mock";
import { onLoad, onSave, onChangeAccountType, validateEmailAddress } from "./AccountFormCC.js";
```

---

## Comprehensive beforeEach

```javascript
describe("AccountFormCC - Unit Tests", () => {
    beforeEach(() => {
        XrmMockGenerator.initialise();

        // Attributes
        XrmMockGenerator.Attribute.createOptionSet("prefix_accounttype", 100000000);
        XrmMockGenerator.Attribute.createString("prefix_firstname", "");
        XrmMockGenerator.Attribute.createString("prefix_lastname", "");
        XrmMockGenerator.Attribute.createString("prefix_corpname", "");
        XrmMockGenerator.Attribute.createString("name", "");
        XrmMockGenerator.Attribute.createString("telephone1", "");
        XrmMockGenerator.Attribute.createString("emailaddress1", "");
        XrmMockGenerator.Attribute.createLookup("prefix_functionallocationid", null);

        // Controls
        XrmMockGenerator.Control.createString({ name: "prefix_firstname", visible: true });
        XrmMockGenerator.Control.createString({ name: "prefix_lastname", visible: true });
        XrmMockGenerator.Control.createString({ name: "prefix_corpname", visible: false });
        XrmMockGenerator.Control.createString({ name: "name", visible: true });

        // Xrm.WebApi
        global.Xrm.WebApi = {
            retrieveRecord: vi.fn().mockResolvedValue({}),
            retrieveMultipleRecords: vi.fn().mockResolvedValue({ entities: [] }),
            createRecord: vi.fn().mockResolvedValue({ id: "test-id" }),
            updateRecord: vi.fn().mockResolvedValue({}),
            deleteRecord: vi.fn().mockResolvedValue({}),
            associateRecord: vi.fn().mockResolvedValue({})
        };
        global.Xrm.Navigation = { openErrorDialog: vi.fn() };
        global.Xrm.Ui = { getFormType: vi.fn().mockReturnValue(1) };
    });

    afterEach(() => { vi.clearAllMocks(); });
});
```

---

## OnLoad — Event Handler Registration

```javascript
it("onLoad: should register event handlers", () => {
    const context = XrmMockGenerator.getEventContext();
    const formContext = context.getFormContext();
    formContext.data.entity.getId = vi.fn().mockReturnValue(null);

    const attr = formContext.getAttribute("prefix_accounttype");
    attr.addOnChange = vi.fn();

    onLoad(context);
    expect(attr.addOnChange).toHaveBeenCalled();
});
```

---

## OnSave — preventDefault

```javascript
it("onSave: should prevent save when validation fails", () => {
    const context = XrmMockGenerator.getEventContext();
    const formContext = context.getFormContext();
    const eventArgs = { preventDefault: vi.fn() };
    context.getEventArgs = vi.fn().mockReturnValue(eventArgs);

    formContext.getAttribute("telephone1").setValue(null);
    formContext.getAttribute("emailaddress1").setValue(null);

    onSave(context);

    expect(global.Xrm.Navigation.openErrorDialog).toHaveBeenCalled();
    expect(eventArgs.preventDefault).toHaveBeenCalled();
});

it("onSave: should allow save when validation passes", () => {
    const context = XrmMockGenerator.getEventContext();
    const eventArgs = { preventDefault: vi.fn() };
    context.getEventArgs = vi.fn().mockReturnValue(eventArgs);
    context.getFormContext().getAttribute("emailaddress1").setValue("user@example.com");

    onSave(context);
    expect(eventArgs.preventDefault).not.toHaveBeenCalled();
});
```

---

## Async Operations — Flushing Promises

```javascript
it("should populate address from Functional Location", async () => {
    const context = XrmMockGenerator.getEventContext();
    const formContext = context.getFormContext();

    formContext.getAttribute("prefix_functionallocationid").setValue([
        { id: "12345678-1234-1234-1234-123456789012", entityType: "msdyn_functionallocation", name: "Test FL" }
    ]);

    global.Xrm.WebApi.retrieveRecord.mockResolvedValueOnce({
        msdyn_address1: "123 Main St", msdyn_city: "Madrid", msdyn_country: "Spain"
    });

    setAddressFromFunctionalLocation(context);
    await new Promise(resolve => setTimeout(resolve, 0)); // flush microtasks

    expect(formContext.getAttribute("address1_line1").getValue()).toBe("123 Main St");
});
```

### Lookup Value Format

Lookups are **always arrays** (even single):

```javascript
// CORRECT
formContext.getAttribute("prefix_functionallocationid").setValue([
    { id: "guid-here", entityType: "msdyn_functionallocation", name: "FL Name" }
]);
// WRONG: single object without array wrapper
```

---

## Error Handling — vi.spyOn Console

```javascript
it("should handle retrieveRecord error gracefully", async () => {
    const context = XrmMockGenerator.getEventContext();
    context.getFormContext().getAttribute("prefix_functionallocationid").setValue([
        { id: "12345678-1234-1234-1234-123456789012", entityType: "msdyn_functionallocation", name: "FL" }
    ]);
    global.Xrm.WebApi.retrieveRecord.mockRejectedValue(new Error("Network error"));
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});

    setAddressFromFunctionalLocation(context);
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(spy).toHaveBeenCalledWith(expect.stringContaining("Error"), expect.any(Error));
    spy.mockRestore();
});
```

---

## associateRecord (N:N)

```javascript
it("onLoad: should associate N:N when FL and accountId exist", async () => {
    const context = XrmMockGenerator.getEventContext();
    const formContext = context.getFormContext();
    const flId = "{12345678-1234-1234-1234-123456789012}";
    const accountId = "{87654321-4321-4321-4321-210987654321}";

    formContext.data.entity.getId = vi.fn().mockReturnValue(accountId);
    formContext.getAttribute("prefix_functionallocationid").setValue([
        { id: flId, entityType: "msdyn_functionallocation", name: "Test FL" }
    ]);
    global.Xrm.WebApi.associateRecord.mockResolvedValue({});

    onLoad(context);
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(global.Xrm.WebApi.associateRecord).toHaveBeenCalledWith(
        "account", accountId.replace(/[{}]/g, ""),
        "msdyn_msdyn_functionallocation_account",
        "msdyn_functionallocation", flId.replace(/[{}]/g, "")
    );
});
```

---

## Validation Functions

```javascript
describe("Email Validation", () => {
    it("should accept valid email", () => {
        const context = XrmMockGenerator.getEventContext();
        context.getFormContext().getAttribute("emailaddress1").setValue("user@example.com");
        expect(validateEmailAddress(context)).toBe(true);
    });

    it("should reject email without @", () => {
        const context = XrmMockGenerator.getEventContext();
        context.getFormContext().getAttribute("emailaddress1").setValue("userexample.com");
        expect(validateEmailAddress(context)).toBe(false);
    });

    it("should accept null (optional field)", () => {
        const context = XrmMockGenerator.getEventContext();
        context.getFormContext().getAttribute("emailaddress1").setValue(null);
        expect(validateEmailAddress(context)).toBe(true);
    });
});
```

---

## Field Visibility & Required Level

```javascript
it("should show individual fields when Individual is selected", () => {
    const context = XrmMockGenerator.getEventContext();
    const formContext = context.getFormContext();
    formContext.getAttribute("prefix_accounttype").setValue(100000000);

    onChangeAccountType(context);

    expect(formContext.getControl("prefix_firstname").getVisible()).toBe(true);
    expect(formContext.getControl("prefix_corpname").getVisible()).toBe(false);
    expect(formContext.getAttribute("prefix_lastname").getRequiredLevel()).toBe("required");
});
```

---

## External SDK Mocking (Omnichannel)

```javascript
beforeEach(() => {
    global.Microsoft = { Apm: { getFocusedSession: vi.fn() } };
});

it("should handle Omnichannel session error gracefully", () => {
    global.Microsoft.Apm.getFocusedSession.mockImplementation(() => { throw new Error("No session"); });
    const spy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const context = XrmMockGenerator.getEventContext();

    expect(() => setQueueIdFromOmnichannelConversation(context)).not.toThrow();
    expect(spy).toHaveBeenCalledWith(expect.stringContaining("error:"), expect.any(Error));
    spy.mockRestore();
});
```

---

## Coverage Guidelines

- Target **>90% branch coverage** on business logic
- `afterEach(() => vi.clearAllMocks())` — always
- Test null/undefined/empty input; both success + error async paths
- `vi.spyOn()` for side effects (console, navigation, preventDefault)
- `mockResolvedValueOnce` / `mockRejectedValue` for varied async scenarios
- Organize tests with comment block headers per lifecycle/category
