---
name: pcf-builder
description: 'Scaffold PowerApps Component Framework (PCF) controls for model-driven and canvas apps. Generates TypeScript components with optional React and Fluent UI v9, proper manifest configuration, dataset and field bindings, and testing setup.'
license: MIT
compatibility:
  - github-copilot-cli
  - claude-code
metadata:
  category: code-generation
  stack: dynamics365-powerplatform
---

# PCF Builder

Scaffold PowerApps Component Framework (PCF) controls with TypeScript, optionally using React and Fluent UI v9. This skill generates production-ready PCF components for model-driven and canvas apps.

## 1. PCF Project Structure

Every PCF control follows this directory layout:

```
{ControlName}/
├── {ControlName}/
│   ├── ControlManifest.Input.xml       # Component manifest
│   ├── index.ts                         # Main component entry point
│   ├── components/                      # React components (if React)
│   │   └── {ControlName}App.tsx
│   ├── hooks/                           # Custom React hooks (if React)
│   ├── services/                        # Data services, API calls
│   ├── types/
│   │   └── index.ts                     # TypeScript interfaces
│   ├── utils/
│   │   └── index.ts                     # Utility functions
│   └── css/
│       └── {ControlName}.css            # Styles
├── package.json
├── tsconfig.json
├── .eslintrc.json
└── README.md
```

- Place the manifest, entry point, and all source code inside the inner `{ControlName}/` folder.
- Keep `package.json`, `tsconfig.json`, and config files at the project root.


## 2. Component Types

### Field Control

A field control is bound to a single column (attribute) on a form. Use it when the component represents or edits one piece of data.

**When to use**: phone formatters, status badges, rich text editors, color pickers, rating controls, file uploaders.

The manifest declares one or more `<property>` elements with `usage="bound"` or `usage="input"`.

### Dataset Control

A dataset control is bound to a view or sub-grid and receives a collection of records. Use it when the component displays or interacts with multiple rows.

**When to use**: Kanban boards, calendar views, custom grids, chart visualizations, card layouts.

The manifest declares a `<data-set>` element instead of (or in addition to) `<property>` elements.


## 3. Naming Convention

Follow the pattern `{Publisher}_{ControlName}` in PascalCase:

| Example | Publisher | Control Name |
|---------|-----------|--------------|
| `Contoso_PhoneValidator` | Contoso | PhoneValidator |
| `Acme_StatusBadge` | Acme | StatusBadge |
| `Fabrikam_KanbanBoard` | Fabrikam | KanbanBoard |

- **Namespace in manifest**: use the publisher prefix in lowercase (e.g., `contoso`).
- Use `{prefix}` as a configurable placeholder throughout templates. Replace it with the actual publisher prefix during scaffolding.


## 4. ControlManifest.Input.xml — Field Type Template

```xml
<?xml version="1.0" encoding="utf-8" ?>
<manifest>
  <control namespace="{prefix}" constructor="{ControlName}" version="1.0.0"
           display-name-key="{ControlName}" description-key="{ControlName}_Desc"
           control-type="standard">
    <property name="value" display-name-key="Value" description-key="Value_Desc"
              of-type="SingleLine.Text" usage="bound" required="true" />
    <resources>
      <code path="index.ts" order="1" />
      <css path="css/{ControlName}.css" order="1" />
    </resources>
  </control>
</manifest>
```

**Common `of-type` values for field controls**:

| of-type | Use case |
|---------|----------|
| `SingleLine.Text` | Short text input |
| `SingleLine.Phone` | Phone numbers |
| `SingleLine.Email` | Email addresses |
| `SingleLine.URL` | URLs |
| `Multiple` | Multi-line text |
| `Whole.None` | Integer values |
| `Decimal` | Decimal values |
| `Currency` | Money values |
| `TwoOptions` | Boolean (yes/no) |
| `DateAndTime.DateOnly` | Date picker |
| `DateAndTime.DateAndTime` | Date-time picker |
| `OptionSet` | Choice column |
| `Lookup.Simple` | Lookup reference |


## 5. index.ts — Vanilla TypeScript Template

```typescript
import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class {ControlName} implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _container: HTMLDivElement;
    private _notifyOutputChanged: () => void;
    private _value: string;

    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._container = container;
        this._notifyOutputChanged = notifyOutputChanged;
        // Initialize component DOM, attach event listeners
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this._value = context.parameters.value.raw ?? "";
        // Update component rendering based on new context
    }

    public getOutputs(): IOutputs {
        return { value: this._value };
    }

    public destroy(): void {
        // Clean up event listeners, intervals, subscriptions
    }
}
```

**Key lifecycle methods**:

- `init()` — Called once when the control loads. Create DOM elements, attach event listeners, initialize state.
- `updateView()` — Called whenever the framework has new data. Re-read parameters and update rendering.
- `getOutputs()` — Called by the framework to collect values the control wants to write back to bound columns.
- `destroy()` — Called when the control is removed from the DOM. Remove event listeners, clear timers, release resources.


## 6. React + Fluent UI Pattern

When the user chooses React (with or without Fluent UI), follow this pattern.

### index.ts (React entry point)

```typescript
import { IInputs, IOutputs } from "./generated/ManifestTypes";
import { createRoot, Root } from "react-dom/client";
import { createElement } from "react";
import { {ControlName}App } from "./components/{ControlName}App";

export class {ControlName} implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _root: Root;
    private _notifyOutputChanged: () => void;
    private _currentValue: string;

    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._notifyOutputChanged = notifyOutputChanged;
        this._root = createRoot(container);
        this.renderReactApp(context);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this.renderReactApp(context);
    }

    private renderReactApp(context: ComponentFramework.Context<IInputs>): void {
        this._root.render(
            createElement({ControlName}App, {
                value: context.parameters.value.raw ?? "",
                onChange: this.handleChange.bind(this),
                isDisabled: context.mode.isControlDisabled,
                isVisible: context.mode.isVisible,
            })
        );
    }

    private handleChange(newValue: string): void {
        this._currentValue = newValue;
        this._notifyOutputChanged();
    }

    public getOutputs(): IOutputs {
        return { value: this._currentValue };
    }

    public destroy(): void {
        this._root.unmount();
    }
}
```

### components/{ControlName}App.tsx (React component with Fluent UI v9)

```tsx
import React, { useState, useCallback } from "react";
import {
    FluentProvider,
    webLightTheme,
    Input,
    Label,
    makeStyles,
} from "@fluentui/react-components";

export interface I{ControlName}AppProps {
    value: string;
    onChange: (newValue: string) => void;
    isDisabled: boolean;
    isVisible: boolean;
}

const useStyles = makeStyles({
    root: {
        display: "flex",
        flexDirection: "column",
        gap: "4px",
    },
});

export const {ControlName}App: React.FC<I{ControlName}AppProps> = ({
    value,
    onChange,
    isDisabled,
    isVisible,
}) => {
    const styles = useStyles();
    const [localValue, setLocalValue] = useState(value);

    const handleChange = useCallback(
        (_: React.ChangeEvent<HTMLInputElement>, data: { value: string }) => {
            setLocalValue(data.value);
            onChange(data.value);
        },
        [onChange]
    );

    if (!isVisible) return null;

    return (
        <FluentProvider theme={webLightTheme}>
            <div className={styles.root}>
                <Label htmlFor="pcf-input">Value</Label>
                <Input
                    id="pcf-input"
                    value={localValue}
                    onChange={handleChange}
                    disabled={isDisabled}
                />
            </div>
        </FluentProvider>
    );
};
```

**Guidelines for React + Fluent UI**:

- Always wrap the React component tree in `<FluentProvider>` with the appropriate theme.
- Use `@fluentui/react-components` (Fluent UI v9), not the older `@fluentui/react` (v8).
- Pass PCF context values as props; do not import PCF types inside React components.
- Handle `isControlDisabled` and `isVisible` from `context.mode`.
- Use `React.memo` or `useMemo` for expensive renderings.
- Unmount the React root in `destroy()` to prevent memory leaks.


## 7. Dataset Component Pattern

### Manifest for dataset control

```xml
<?xml version="1.0" encoding="utf-8" ?>
<manifest>
  <control namespace="{prefix}" constructor="{ControlName}" version="1.0.0"
           display-name-key="{ControlName}" description-key="{ControlName}_Desc"
           control-type="standard">
    <data-set name="dataSet" display-name-key="DataSet" />
    <resources>
      <code path="index.ts" order="1" />
      <css path="css/{ControlName}.css" order="1" />
    </resources>
  </control>
</manifest>
```

### Working with datasets in index.ts

```typescript
public updateView(context: ComponentFramework.Context<IInputs>): void {
    const dataSet = context.parameters.dataSet;

    if (dataSet.loading) return;

    // Column metadata
    const columns = dataSet.columns.sort((a, b) => a.order - b.order);

    // Record IDs
    const recordIds = dataSet.sortedRecordIds;

    // Iterate records
    recordIds.forEach((id) => {
        const record = dataSet.records[id];
        columns.forEach((col) => {
            const value = record.getFormattedValue(col.name);
            // Render cell value
        });
    });

    // Paging
    if (dataSet.paging.hasNextPage) {
        dataSet.paging.loadNextPage();
    }

    // Sorting
    // dataSet.sorting contains current sort info
    // Use dataSet.refresh() after changing sort/filter

    // Selection
    const selectedIds = dataSet.getSelectedRecordIds();
    // dataSet.setSelectedRecordIds([...ids]) to set selection

    // Filtering
    // dataSet.filtering provides filter expression access
}
```

**Key dataset APIs**:

| API | Purpose |
|-----|---------|
| `dataSet.columns` | Array of column metadata (name, displayName, dataType, order) |
| `dataSet.sortedRecordIds` | Ordered array of record IDs in the current view |
| `dataSet.records[id]` | Access a specific record by ID |
| `record.getFormattedValue(colName)` | Get display-formatted value |
| `record.getValue(colName)` | Get raw value |
| `dataSet.paging` | Paging control (hasNextPage, hasPreviousPage, loadNextPage, etc.) |
| `dataSet.sorting` | Current sort state |
| `dataSet.filtering` | Current filter state |
| `dataSet.getSelectedRecordIds()` | Get selected record IDs |
| `dataSet.setSelectedRecordIds(ids)` | Set record selection |
| `dataSet.refresh()` | Refresh the dataset |
| `dataSet.openDatasetItem(ref)` | Open a record form |


## 8. Common PCF Patterns

Use these as starting points when the user describes their use case:

| Pattern | Type | Description |
|---------|------|-------------|
| Phone number formatter/validator | Field | Formats and validates phone numbers with international support |
| Status badge with custom colors | Field | Renders an OptionSet value as a colored badge |
| Rich text editor | Field | Multi-line text with WYSIWYG editing capabilities |
| File upload with preview | Field | Upload files with drag-and-drop, display image/file previews |
| Custom lookup/search | Field | Enhanced lookup with search-as-you-type and custom rendering |
| Star rating | Field | Interactive star-based rating control for numeric fields |
| Kanban board | Dataset | Drag-and-drop columns representing status, cards for records |
| Calendar view | Dataset | Display records on a calendar by date fields |
| Card gallery | Dataset | Render records as visually rich cards instead of grid rows |
| Map view | Dataset | Plot records with address/coordinates on an interactive map |

When generating a specific pattern, include domain-specific validation, accessibility (ARIA attributes), and responsive design.


## 9. Init Commands

### Scaffold a new PCF project

```bash
# Field control — vanilla TypeScript
pac pcf init --namespace {prefix} --name {ControlName} --template field

# Field control — React
pac pcf init --namespace {prefix} --name {ControlName} --template field --framework react

# Dataset control — vanilla TypeScript
pac pcf init --namespace {prefix} --name {ControlName} --template dataset

# Dataset control — React
pac pcf init --namespace {prefix} --name {ControlName} --template dataset --framework react
```

### Install dependencies

```bash
npm install

# If using Fluent UI v9
npm install @fluentui/react-components
```

> **Prerequisite**: The user must have [Power Platform CLI (pac)](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction) installed. If `pac` is not found, instruct the user to install it via `dotnet tool install --global Microsoft.PowerApps.CLI.Tool` or the VS Code Power Platform extension.


## 10. Build and Test

```bash
# Build the control
npm run build

# Launch the PCF test harness (opens browser with a test page)
npm start watch

# Push directly to a connected Dataverse environment
pac pcf push --publisher-prefix {prefix}
```

**Test harness tips**:

- The test harness simulates the host environment; use it for rapid iteration.
- Test with different form factors (phone, tablet, desktop) in the harness.
- Verify `isControlDisabled` and `isVisible` toggling in the harness properties panel.
- For dataset controls, load sample CSV data in the harness.

**Production packaging**:

```bash
# Create a solution project (one level above the control folder)
pac solution init --publisher-name {publisher} --publisher-prefix {prefix}

# Add the PCF project reference to the solution
pac solution add-reference --path ./{ControlName}

# Build the solution (.zip)
msbuild /t:build /restore

# Import solution into Dataverse
pac solution import --path bin/Debug/{SolutionName}.zip
```


## 11. Workflow

When a user requests a new PCF control, follow these steps:

1. **Gather requirements** — Ask the user for:
   - Control name (PascalCase, e.g., `PhoneValidator`)
   - Publisher prefix (lowercase, e.g., `contoso`)
   - Component type: **field** or **dataset**
   - Bound properties (name, type, required)
   - UI library preference: **vanilla TypeScript**, **React**, or **React + Fluent UI v9**
   - Target app type: model-driven, canvas, or both

2. **Generate ControlManifest.Input.xml** — Based on the component type and bound properties.

3. **Generate index.ts** — Use the vanilla or React template depending on user preference. Wire up lifecycle methods.

4. **Generate React component** (if React chosen) — Create `components/{ControlName}App.tsx` with props interface, Fluent UI provider if selected, and event handlers.

5. **Generate supporting files** — Types in `types/index.ts`, utility functions in `utils/index.ts`, styles in `css/{ControlName}.css`.

6. **Generate README.md** — Include setup instructions, usage guide, and configuration reference for the control.

7. **Provide next steps** — Show the user the init, build, and test commands. Remind them to test in the harness before deploying.


## Additional Guidelines

- Generate accessible components with proper ARIA attributes and keyboard navigation.
- Use `context.resources.getString()` for localized strings when available.
- Handle `context.mode.isControlDisabled` and `context.mode.isVisible` appropriately.
- For canvas apps, respect `context.mode.allocatedWidth` and `context.mode.allocatedHeight`.
- Scope DOM access to the provided container — never use `document.getElementById()`.
- Clean up all resources (event listeners, timers, subscriptions, React roots) in `destroy()`.
