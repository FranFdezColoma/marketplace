---
name: pcf-builder
description: Scaffold and build PowerApps Component Framework (PCF) controls for Dynamics 365 and Power Platform. Guides through initialization, manifest configuration, implementation, and deployment. Use when the user needs to create a new PCF control or modify an existing one.
---

# PCF Builder for Power Platform

## Control Types

| Type | Bound To | Use Case |
|------|----------|----------|
| **Field** | Single column | Custom editors, formatted displays |
| **Dataset** | View/dataset | Custom grids, galleries, visualizations |

---

## Development Workflow

### 1. Initialize

```powershell
mkdir [ControlName] && cd [ControlName]
pac pcf init --namespace [Namespace] --name [ControlName] --template field
npm install
```

### 2. Manifest (ControlManifest.Input.xml)

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest>
  <control namespace="[Namespace]" constructor="[ControlName]" version="1.0.0"
           display-name-key="[ControlName]" description-key="[ControlName]_Desc"
           control-type="standard">
    <property name="value" display-name-key="Value"
              of-type="SingleLine.Text" usage="bound" required="true" />
    <property name="maxLength" display-name-key="MaxLength"
              of-type="Whole.None" usage="input" required="false" default-value="100" />
    <resources>
      <code path="index.ts" order="1" />
      <css path="css/[ControlName].css" order="1" />
    </resources>
    <feature-usage>
      <uses-feature name="Utility" required="true" />
      <uses-feature name="WebAPI" required="true" />
    </feature-usage>
  </control>
</manifest>
```

### 3. Implement (index.ts)

```typescript
import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class [ControlName] implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _container: HTMLDivElement;
    private _notifyOutputChanged: () => void;
    private _value: string;

    /**
     * Initializes the control instance. Called once when the control is loaded.
     * @param context - The entire property bag available to control via Context Object.
     * @param notifyOutputChanged - A callback method to alert the framework that the control has new outputs.
     * @param state - A piece of data that persists in one session for a single user.
     * @param container - The HTML container element.
     */
    public init(context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void, state: ComponentFramework.Dictionary,
        container: HTMLDivElement): void {
        this._notifyOutputChanged = notifyOutputChanged;
        this._container = container;
        this._value = context.parameters.value.raw || "";
        this.renderControl();
    }

    /**
     * Called when any value in the property bag has changed.
     * @param context - The entire property bag available to control via Context Object.
     */
    public updateView(context: ComponentFramework.Context<IInputs>): void {
        const newValue = context.parameters.value.raw || "";
        if (newValue !== this._value) {
            this._value = newValue;
            this.renderControl();
        }
    }

    /**
     * Returns the current output values of the control.
     */
    public getOutputs(): IOutputs { return { value: this._value }; }

    /**
     * Cleans up the component before removal from the DOM.
     * Remove event listeners, cancel pending requests, and release large objects.
     */
    public destroy(): void { /* Remove listeners, clear timers */ }

    /**
     * Renders or re-renders the control into the container element.
     */
    private renderControl(): void {
        this._container.innerHTML = "";
        const input = document.createElement("input");
        input.type = "text";
        input.value = this._value;
        input.addEventListener("change", (e) => {
            this._value = (e.target as HTMLInputElement).value;
            this._notifyOutputChanged();
        });
        this._container.appendChild(input);
    }
}
```

### 4. Build & Test

```powershell
npm run build        # Compile
npm start            # Test harness
npm start watch      # Watch mode
```

### 5. Package & Deploy

```powershell
mkdir [ControlName]Solution && cd [ControlName]Solution
pac solution init --publisher-name [publisher] --publisher-prefix [prefix]
pac solution add-reference --path ..
msbuild /t:build /restore
pac pcf push --publisher-prefix [prefix]  # dev push
```

---

## React Integration

```powershell
npm install react react-dom
npm install -D @types/react @types/react-dom
```

```typescript
import * as React from "react";
import * as ReactDOM from "react-dom";
import { MyComponent } from "./components/MyComponent";

/** Called once when the control loads. Sets up the initial React render. */
public init(...): void { this.renderReact(context); }
/** Called when property bag values change. Re-renders the React tree. */
public updateView(context): void { this.renderReact(context); }
/** Cleans up the React component tree before the control is removed. */
public destroy(): void { ReactDOM.unmountComponentAtNode(this._container); }

/** Renders or re-renders the React component into the container. */
private renderReact(context): void {
    ReactDOM.render(React.createElement(MyComponent, {
        value: context.parameters.value.raw,
        onChange: (v) => { this._value = v; this._notifyOutputChanged(); }
    }), this._container);
}
```

---

## CLI Quick Reference

| Command | Purpose |
|---------|---------|
| `pac pcf init` | Initialize control |
| `npm run build` | Compile |
| `npm start` | Test harness |
| `pac pcf push` | Push to env |
| `pac solution init` | Create solution project |
| `msbuild /t:build /restore` | Build solution |
| `pac solution import` | Import to env |

---

## Property Types

| PCF Type | Use |
|----------|-----|
| SingleLine.Text | Text |
| Whole.None | Integer |
| Decimal | Decimal |
| Currency | Money |
| DateAndTime.DateOnly / DateAndTime | Date/DateTime |
| TwoOptions | Boolean |
| OptionSet | Choice |
| Lookup.Simple | Lookup |
| Multiple | Multiline text |

---

## Best Practices

See `./reference/pcf-best-practices.md` for performance, accessibility, localization, responsive design, and testing.
