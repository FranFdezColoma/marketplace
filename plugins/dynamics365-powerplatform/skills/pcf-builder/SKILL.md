---
name: pcf-builder
description: Crea un PCF Control (PowerApps Component Framework) completo con TypeScript, React hooks y Fluent UI V9. Genera el proyecto con PCF CLI, componente funcional, manifest, estilos, tests Jest y configuración de despliegue con PAC CLI. Úsalo cuando el usuario necesite "crea un pcf", "componente pcf", "control personalizado power apps", "pcf control", "custom control", "field component", "dataset component".
license: MIT
compatibility: Designed for GitHub Copilot CLI or Claude Code in Power Platform / Dataverse development projects. Requires Node.js >= 16, npm >= 8, and PAC CLI >= 2.3.1.
metadata:
  author: Francisco Fernandez Coloma
  version: "1.0.0"
  argument-hint: "[descripción del componente: tipo (field/dataset), propósito, campos del manifest]"
---

# PCF Control Builder

**Triggers**: pcf-builder, crea un pcf, componente pcf, custom control, field component, dataset component
**Aliases**: /pcf, /pcf-builder, /control

## Referencias

- **Naming**: [naming-conventions.md](../../references/naming-conventions.md)
- **Patrones**: [dataverse-patterns.md](../../references/dataverse-patterns.md)

---

## Instrucciones

### Paso 1: Verificar Prerrequisitos

```powershell
node --version      # >= 16
npm --version       # >= 8
pac help            # >= 2.3.1
```

### Paso 2: Recopilar Información

Usa `AskUserQuestion` si la información no está clara:

1. **"¿Qué tipo de control?"** — Field (single field) o Dataset (tabla/lista de registros)
2. **"¿Nombre del componente?"** — PascalCase con prefijo publisher (ej: `src_CustomerRating`)
3. **"¿Qué hace el componente?"** — Descripción funcional
4. **"¿Qué propiedades expone el manifest?"** — Tipos de datos que acepta/devuelve
5. **"¿Requiere datos de Dataverse?"** — Para incluir WebAPI en el manifest
6. **"¿Framework de UI?"** — React (recomendado) o vanilla TypeScript

### Paso 3: Inicializar el Proyecto PCF

```powershell
# Crear directorio y proyecto
$componentName = "src_CustomerRating"  # Nombre del componente
$namespace = "Fran"

New-Item -ItemType Directory -Force -Path "./pcf/$componentName"
cd "./pcf/$componentName"

# Inicializar con PAC CLI
pac pcf init --namespace $namespace --name $componentName --template field --run-npm-install

# Instalar dependencias adicionales para React + Fluent UI
npm install @fluentui/react-components@^9 @fluentui/react-icons@^2
npm install --save-dev @types/react @types/react-dom @testing-library/react @testing-library/jest-dom
```

### Paso 4: Diseñar el Manifest

Genera el `ControlManifest.Input.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest>
  <control namespace="Fran" constructor="src_CustomerRating" 
           version="1.0.0" display-name-key="src_CustomerRating_Display_Key"
           description-key="src_CustomerRating_Desc_Key" 
           control-type="standard" preview-image="imgs/preview.png">

    <!-- Propiedades del campo -->
    <property name="value" display-name-key="Property_value_Display_Key"
              description-key="Property_value_Desc_Key" of-type="Whole.None"
              usage="bound" required="true" />

    <property name="maxRating" display-name-key="Property_maxRating_Display_Key"
              description-key="Property_maxRating_Desc_Key" of-type="Whole.None"
              usage="input" required="false" default-value="5" />

    <property name="readOnly" display-name-key="Property_readOnly_Display_Key"
              description-key="Property_readOnly_Desc_Key" of-type="TwoOptions"
              usage="input" required="false" default-value="false" />

    <!-- Recursos del componente -->
    <resources>
      <code path="index.ts" order="1" />
      <css path="css/CustomerRating.css" order="1" />
      <resx path="strings/CustomerRating.1033.resx" version="1.0.0" />
    </resources>

    <!-- Usar WebAPI si necesitas acceso a Dataverse -->
    <!-- <feature-usage>
      <uses-feature name="WebAPI" required="true" />
    </feature-usage> -->

  </control>
</manifest>
```

### Paso 5: Generar el Componente

```typescript
// index.ts — Ciclo de vida del componente
import { IInputs, IOutputs } from "./generated/ManifestTypes";
import * as React from "react";
import { createRoot, Root } from "react-dom/client";
import { CustomerRatingComponent, CustomerRatingProps } from "./components/CustomerRatingComponent";

export class src_CustomerRating implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _container: HTMLDivElement;
    private _notifyOutputChanged: () => void;
    private _currentValue: number;
    private _isReadOnly: boolean;
    private _root: Root;

    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._container = container;
        this._notifyOutputChanged = notifyOutputChanged;
        this._isReadOnly = context.mode.isControlDisabled;
        this._root = createRoot(this._container);
        
        this._renderComponent(context);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this._isReadOnly = context.mode.isControlDisabled;
        this._renderComponent(context);
    }

    public getOutputs(): IOutputs {
        return {
            value: this._currentValue
        };
    }

    public destroy(): void {
        this._root.unmount();
    }

    private _renderComponent(context: ComponentFramework.Context<IInputs>): void {
        const props: CustomerRatingProps = {
            value: context.parameters.value.raw ?? 0,
            maxRating: context.parameters.maxRating.raw ?? 5,
            readOnly: this._isReadOnly,
            onChange: (newValue: number) => {
                if (!this._isReadOnly) {
                    this._currentValue = newValue;
                    this._notifyOutputChanged();
                }
            }
        };

        this._root.render(
            React.createElement(CustomerRatingComponent, props)
        );
    }
}
```

```typescript
// components/CustomerRatingComponent.tsx — Componente React con Fluent UI
import * as React from "react";
import {
    FluentProvider,
    webLightTheme,
    Rating,
    RatingDisplay,
    makeStyles,
    tokens
} from "@fluentui/react-components";

const useStyles = makeStyles({
    root: {
        display: "flex",
        alignItems: "center",
        gap: tokens.spacingHorizontalS,
        padding: tokens.spacingVerticalXS,
    }
});

export interface CustomerRatingProps {
    value: number;
    maxRating: number;
    readOnly: boolean;
    onChange: (value: number) => void;
}

export const CustomerRatingComponent: React.FC<CustomerRatingProps> = ({
    value, maxRating, readOnly, onChange
}) => {
    const styles = useStyles();

    return (
        <FluentProvider theme={webLightTheme}>
            <div className={styles.root}>
                {readOnly ? (
                    <RatingDisplay
                        value={value}
                        max={maxRating}
                        aria-label={`Rating: ${value} of ${maxRating}`}
                    />
                ) : (
                    <Rating
                        value={value}
                        max={maxRating}
                        onChange={(_, data) => onChange(data.value)}
                        aria-label="Customer rating"
                    />
                )}
            </div>
        </FluentProvider>
    );
};
```

```typescript
// __tests__/CustomerRatingComponent.test.tsx — Tests Jest
import * as React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { CustomerRatingComponent } from "../components/CustomerRatingComponent";

describe("CustomerRatingComponent", () => {
    it("renders rating display when readOnly is true", () => {
        render(
            <CustomerRatingComponent value={3} maxRating={5} readOnly={true} onChange={jest.fn()} />
        );
        expect(screen.getByLabelText("Rating: 3 of 5")).toBeInTheDocument();
    });

    it("calls onChange when rating changes in edit mode", () => {
        const onChangeMock = jest.fn();
        render(
            <CustomerRatingComponent value={2} maxRating={5} readOnly={false} onChange={onChangeMock} />
        );
        // Test interaction...
    });
});
```

### Paso 6: Compilar y Testear

```powershell
# Ejecutar tests
npm test -- --coverage

# Build de producción
npm run build

# Test en el test harness local
npm start  # Abre http://localhost:8181/
```

### Paso 7: Desplegar con PAC CLI

```powershell
# Autenticar si es necesario
pac auth list

# Push a Dataverse (desarrollo)
pac pcf push --publisher-prefix src

# Para incluir en una solución
pac solution add-reference --path "./"
```

### Paso 8: Resumen Final

- Proyecto PCF generado con estructura completa
- Tests ejecutados: PASS ✅
- Componente disponible en Dataverse: `src_CustomerRating`
- Próximos pasos: añadir a solución, code review (`/code-review`), pipeline ALM (`/alm-pipeline`)
