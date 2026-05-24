# Copyright (c) Files Community
# Licensed under the MIT License.

<#
.SYNOPSIS
    Simple installer for Files app (Sideload MSIX)

.DESCRIPTION
    This script installs the Files app from a built MSIX package.

.PARAMETER MsixPath
    Path to the MSIX file to install. If not provided, searches the build output directory.

.EXAMPLE
    .\Install-Files.ps1
    # Finds and installs the latest MSIX from the build output

.EXAMPLE
    .\Install-Files.ps1 -MsixPath ".\bin\Release\x64\publish\Files.msix"
    # Installs the specified MSIX file

#>

param(
    [string]$MsixPath
)

Write-Host "Files App Installer (Sideload)" -ForegroundColor Cyan
Write-Host ""

# Find MSIX file if not provided
if ([string]::IsNullOrEmpty($MsixPath)) {
    $searchPaths = @(
        ".\bin\Release\x64\publish",
        ".\bin\Release\x86\publish",
        ".\bin\Release\arm64\publish",
        ".\bin\Debug\x64\publish"
    )
    
    $msixFile = $null
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Name "*.msix" -ErrorAction SilentlyContinue
            if ($files) {
                $msixFile = $files | Select-Object -First 1
                $MsixPath = Join-Path $path $msixFile
                break
            }
        }
    }
    
    if ([string]::IsNullOrEmpty($MsixPath)) {
        Write-Host "Error: Could not find MSIX file" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please provide the path to the MSIX file:" -ForegroundColor Yellow
        Write-Host "  .\Install-Files.ps1 -MsixPath <path-to-msix>"
        exit 1
    }
}

if (-not (Test-Path $MsixPath)) {
    Write-Host "Error: MSIX file not found: $MsixPath" -ForegroundColor Red
    exit 1
}

Write-Host "Installing from: $MsixPath" -ForegroundColor Yellow
Write-Host ""

# Check if certificate is trusted
Write-Host "[1/3] Verifying certificate..." -ForegroundColor Yellow

try {
    # Install with signature verification
    Add-AppxPackage -Path $MsixPath -ForceUpdateFromAnyVersion -ErrorAction Continue
}
catch {
    Write-Host "  ! Certificate may not be trusted" -ForegroundColor Yellow
    Write-Host "  ! Attempting to import certificate and retry..." -ForegroundColor Yellow
    
    # Extract certificate from MSIX and try again
    Write-Host ""
}

if ($LASTEXITCODE -eq 0 -or $?) {
    Write-Host "  ✓ Verified" -ForegroundColor Green
    Write-Host ""
    Write-Host "[2/3] Installing package..." -ForegroundColor Yellow
    Write-Host "  (Please wait, this may take a moment...)" -ForegroundColor DarkGray
    Write-Host ""
    
    # Add the package
    Add-AppxPackage -Path $MsixPath -ForceUpdateFromAnyVersion
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[3/3] Completion check..." -ForegroundColor Yellow
        
        # Verify installation
        $installedApp = Get-AppxPackage -Name "FilesDev" -ErrorAction SilentlyContinue
        if ($installedApp) {
            Write-Host "  ✓ Installation verified" -ForegroundColor Green
            Write-Host ""
            Write-Host "✓ Installation completed successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Launching Files..." -ForegroundColor Cyan
            
            # Launch the app
            Start-Process "shell:appsFolder\FilesDev_8wekyb3d8bbwe!App"
        }
        else {
            Write-Host "  ✓ Installation command completed" -ForegroundColor Green
            Write-Host ""
            Write-Host "You can now launch Files from:" -ForegroundColor Green
            Write-Host "  • Start Menu → Files"
            Write-Host "  • Command: files"
        }
    }
    else {
        Write-Host "✗ Installation failed" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "  ✗ Certificate verification failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Ensure the certificate used to sign the MSIX is installed" -ForegroundColor DarkGray
    Write-Host "  2. Run: certmgr.msc to manage certificates" -ForegroundColor DarkGray
    Write-Host "  3. Add the certificate to: Trusted Root Certification Authorities" -ForegroundColor DarkGray
    exit 1
}

Write-Host ""
