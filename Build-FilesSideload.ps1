# Copyright (c) Files Community
# Licensed under the MIT License.

<#
.SYNOPSIS
    Build Files app for Windows without Microsoft Store paywall (Sideload version)

.DESCRIPTION
    This script builds the Files app as a sideload MSIX package that can be installed
    on Windows without purchasing from the Microsoft Store.

.PARAMETER Platform
    Target platform: x64, x86, or arm64. Default: x64

.PARAMETER Configuration
    Build configuration: Debug or Release. Default: Release

.PARAMETER SigningCertificatePath
    Path to the code signing certificate (.pfx file). If not provided, a self-signed
    certificate will be generated.

.PARAMETER SigningCertificatePassword
    Password for the signing certificate

.EXAMPLE
    .\Build-FilesSideload.ps1
    # Builds for x64 Release configuration with auto-generated certificate

.EXAMPLE
    .\Build-FilesSideload.ps1 -Platform arm64 -Configuration Debug
    # Builds for ARM64 Debug configuration

#>

param(
    [ValidateSet("x64", "x86", "arm64")]
    [string]$Platform = "x64",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [string]$SigningCertificatePath,
    [securestring]$SigningCertificatePassword
)

# Configuration
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SolutionPath = Join-Path $ProjectRoot "Files.slnx"
$AppProjectPath = Join-Path $ProjectRoot "src\Files.App\Files.App.csproj"
$BuildOutputDir = Join-Path $ProjectRoot "bin\$Configuration\$Platform\publish"
$CertName = "FilesCommunitySideload"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Files App Build Script (Sideload)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check requirements
Write-Host "[1/6] Checking requirements..." -ForegroundColor Yellow
$dotnetVersion = dotnet --version
Write-Host "  ✓ .NET SDK: $dotnetVersion"

try {
    $msbuildPath = (Get-Command msbuild -ErrorAction Stop).Source
    Write-Host "  ✓ MSBuild: $msbuildPath"
}
catch {
    Write-Host "  ✗ MSBuild not found. Please install Visual Studio 2022 or MSBuild." -ForegroundColor Red
    exit 1
}

# Step 2: Restore packages
Write-Host "[2/6] Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore $SolutionPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Restore failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Packages restored"

# Step 3: Build project
Write-Host "[3/6] Building Files ($Platform - $Configuration)..." -ForegroundColor Yellow
msbuild $SolutionPath `
    -t:Restore,Build `
    -p:Configuration=$Configuration `
    -p:Platform=$Platform `
    -p:AppxPackageSigningTimestampDigestAlgorithm=SHA256 `
    -v:minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Build completed"

# Step 4: Generate or verify signing certificate
Write-Host "[4/6] Setting up signing certificate..." -ForegroundColor Yellow

if ([string]::IsNullOrEmpty($SigningCertificatePath)) {
    # Generate self-signed certificate
    $certPath = Join-Path $env:TEMP "$CertName.pfx"
    
    # Check if certificate already exists in store
    $existingCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -contains "CN=$CertName" }
    
    if ($null -eq $existingCert) {
        Write-Host "  Generating self-signed certificate..."
        
        if ([string]::IsNullOrEmpty($SigningCertificatePassword)) {
            $SigningCertificatePassword = ConvertTo-SecureString -String "password" -Force -AsPlainText
        }
        
        $cert = New-SelfSignedCertificate `
            -Type CodeSigningCert `
            -Subject "CN=$CertName" `
            -CertStoreLocation "Cert:\CurrentUser\My" `
            -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3") `
            -NotAfter (Get-Date).AddYears(10)
        
        Export-PfxCertificate `
            -Cert $cert `
            -FilePath $certPath `
            -Password $SigningCertificatePassword | Out-Null
        
        Write-Host "  ✓ Certificate created: $certPath"
    }
    else {
        Write-Host "  ✓ Using existing certificate from store"
    }
}
else {
    Write-Host "  ✓ Using provided certificate: $SigningCertificatePath"
}

# Step 5: Find MSIX package
Write-Host "[5/6] Locating build artifacts..." -ForegroundColor Yellow

$msixFiles = Get-ChildItem -Path $BuildOutputDir -Name "*.msix*" -ErrorAction SilentlyContinue
if ($null -eq $msixFiles) {
    Write-Host "  ! No MSIX files found. Checking build output..." -ForegroundColor Yellow
    if (Test-Path $BuildOutputDir) {
        Get-ChildItem $BuildOutputDir | Select-Object Name
    }
    else {
        Write-Host "  ! Build output directory not found: $BuildOutputDir" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ✓ Build artifacts found:"
    $msixFiles | ForEach-Object { Write-Host "    • $_" }
}

# Step 6: Installation instructions
Write-Host "[6/6] Generating installation instructions..." -ForegroundColor Yellow

$installScript = Join-Path $ProjectRoot "Install-Files.ps1"
@"
# Files App Installation Script (Sideload)
# This script installs the Files app without Microsoft Store

`$BuildDir = '$BuildOutputDir'
`$MsixFile = Get-ChildItem -Path `$BuildDir -Name "*.msix" | Select-Object -First 1

if (`$null -eq `$MsixFile) {
    Write-Host "Error: MSIX file not found in `$BuildDir"
    exit 1
}

`$MsixPath = Join-Path `$BuildDir `$MsixFile.Name
Write-Host "Installing: `$MsixPath"

# Add the app package
Add-AppxPackage -Path `$MsixPath

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✓ Installation completed successfully!" -ForegroundColor Green
    Write-Host "You can now launch Files from the Start Menu or by running: files"
}
else {
    Write-Host "✗ Installation failed" -ForegroundColor Red
    exit 1
}
"@ | Out-File -FilePath $installScript -Encoding UTF8

Write-Host "  ✓ Installation script created: $installScript"
Write-Host ""

# Summary
Write-Host "==================================" -ForegroundColor Green
Write-Host "Build Completed Successfully!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "Build Output:" -ForegroundColor Cyan
Write-Host "  Location: $BuildOutputDir"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run: .\Install-Files.ps1"
Write-Host "  2. Launch Files from the Start Menu"
Write-Host ""
Write-Host "To share this build:" -ForegroundColor Cyan
Write-Host "  • Compress the MSIX file and distribute"
Write-Host "  • Recipient can install via: Add-AppxPackage -Path <path-to-msix>"
Write-Host ""
