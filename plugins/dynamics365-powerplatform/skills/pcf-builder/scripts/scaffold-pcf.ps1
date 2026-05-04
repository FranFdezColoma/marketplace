<#
.SYNOPSIS
    Scaffolds a new PCF control project with best-practice structure.

.DESCRIPTION
    Creates a PCF control project with proper directory structure,
    manifest, component class, CSS file, and optional React setup.

.PARAMETER ControlName
    The name of the PCF control.

.PARAMETER Namespace
    The namespace for the control.

.PARAMETER Template
    The control template: field or dataset.

.PARAMETER UseReact
    Whether to include React setup.

.PARAMETER OutputPath
    The output directory. Defaults to current directory.

.EXAMPLE
    .\scaffold-pcf.ps1 -ControlName "RatingStars" -Namespace "Contoso.Controls" -Template field

.EXAMPLE
    .\scaffold-pcf.ps1 -ControlName "CustomGrid" -Namespace "Contoso.Controls" -Template dataset -UseReact
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ControlName,

    [Parameter(Mandatory = $true)]
    [string]$Namespace,

    [Parameter(Mandatory = $false)]
    [ValidateSet("field", "dataset")]
    [string]$Template = "field",

    [Parameter(Mandatory = $false)]
    [switch]$UseReact,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

$ErrorActionPreference = "Stop"

$controlDir = Join-Path $OutputPath $ControlName

# Check if pac cli is available
$pacAvailable = Get-Command "pac" -ErrorAction SilentlyContinue

if (-not $pacAvailable) {
    Write-Warning "PAC CLI not found. Please install it: https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction"
    Write-Warning "Install via: dotnet tool install --global Microsoft.PowerApps.CLI.Tool"
    exit 1
}

Write-Host "Scaffolding PCF control: $ControlName" -ForegroundColor Cyan
Write-Host "  Namespace: $Namespace"
Write-Host "  Template:  $Template"
Write-Host "  React:     $($UseReact.IsPresent)"
Write-Host ""

# Initialize PCF project
New-Item -ItemType Directory -Force -Path $controlDir | Out-Null
Push-Location $controlDir

try {
    # Initialize PCF project
    Write-Host "Initializing PCF project..." -ForegroundColor Yellow
    pac pcf init --namespace $Namespace --name $ControlName --template $Template --run-npm-install false

    # Create CSS directory and file
    $cssDir = Join-Path $controlDir "$ControlName\css"
    New-Item -ItemType Directory -Force -Path $cssDir | Out-Null

    $cssContent = @"
/* ${ControlName} PCF Control Styles */

.${ControlName}-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: 100%;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.${ControlName}-container:focus-within {
    outline: 2px solid #0078d4;
    outline-offset: -2px;
}

/* Responsive breakpoints */
@media (max-width: 480px) {
    .${ControlName}-container {
        padding: 4px;
    }
}
"@
    Set-Content -Path (Join-Path $cssDir "${ControlName}.css") -Value $cssContent -Encoding UTF8

    # Install dependencies
    Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
    npm install --quiet

    if ($UseReact.IsPresent) {
        Write-Host "Adding React dependencies..." -ForegroundColor Yellow
        npm install react react-dom --quiet
        npm install -D @types/react @types/react-dom --quiet

        # Create components directory
        $componentsDir = Join-Path $controlDir "$ControlName\components"
        New-Item -ItemType Directory -Force -Path $componentsDir | Out-Null

        $reactComponentContent = @"
import * as React from "react";

export interface I${ControlName}Props {
    value: string | null;
    disabled: boolean;
    onChange: (newValue: string) => void;
}

export const ${ControlName}Component: React.FC<I${ControlName}Props> = (props) => {
    const { value, disabled, onChange } = props;

    const handleChange = React.useCallback(
        (event: React.ChangeEvent<HTMLInputElement>) => {
            onChange(event.target.value);
        },
        [onChange]
    );

    return (
        <div className="${ControlName}-container">
            <input
                type="text"
                value={value || ""}
                disabled={disabled}
                onChange={handleChange}
                aria-label="${ControlName}"
            />
        </div>
    );
};
"@
        Set-Content -Path (Join-Path $componentsDir "${ControlName}Component.tsx") -Value $reactComponentContent -Encoding UTF8
    }

    # Build to verify setup
    Write-Host "Building control..." -ForegroundColor Yellow
    npm run build

    Write-Host ""
    Write-Host "PCF control scaffolded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Project location: $controlDir"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. cd $controlDir"
    Write-Host "  2. Edit $ControlName\ControlManifest.Input.xml (configure properties)"
    Write-Host "  3. Implement control logic in $ControlName\index.ts"
    Write-Host "  4. npm start (launch test harness)"
    Write-Host "  5. npm run build (build for deployment)"
    Write-Host "  6. pac pcf push --publisher-prefix [prefix] (deploy to environment)"
}
finally {
    Pop-Location
}
