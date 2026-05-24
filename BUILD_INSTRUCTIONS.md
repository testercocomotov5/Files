# Files App - Build Instructions for Windows (Without Paywall)

This guide explains how to build the Files app for Windows as a **sideload version without Microsoft Store paywall**.

## What is the "Paywall"?

The Files app is available for purchase on the Microsoft Store. Building it as a **sideload** version allows you to install and run it locally on Windows without paying, since it's compiled directly from the source code.

## Prerequisites

You'll need a **Windows machine** with the following installed:

1. **Visual Studio 2022** (or later)
   - Download from: https://visualstudio.microsoft.com/
   - Required workloads:
     - Desktop development with C++
     - .NET desktop development
     - Windows App SDK (install via Visual Studio Installer)

2. **.NET SDK 10.0.102** (or later)
   - Download from: https://dotnet.microsoft.com/download

3. **MSBuild** (included with Visual Studio)

4. **Windows SDK** (included with Visual Studio)

## Build Steps

### Step 1: Open the Repository

```bash
cd /path/to/Files
```

### Step 2: Configure the Project

The app has different build configurations for different distributions:
- `Dev` - Development build
- `SideloadStable` - Sideload stable release
- `SideloadPreview` - Sideload preview release
- `StoreStable` - Microsoft Store stable release (with paywall)
- `StorePreview` - Microsoft Store preview release (with paywall)

To build **without paywall**, use the **`SideloadStable`** or **`Dev`** environment.

### Step 3: Restore NuGet Packages

On Windows Command Prompt or PowerShell:

```bash
dotnet restore Files.slnx
```

Or using NuGet:

```bash
nuget restore Files.slnx
```

### Step 4: Build the Project

Using MSBuild (recommended for MSIX packaging):

```powershell
# For x64 (64-bit)
msbuild Files.slnx `
  -t:Restore,Build `
  -p:Configuration=Release `
  -p:Platform=x64 `
  -p:AppxPackageSigningTimestampDigestAlgorithm=SHA256
```

Or for multiple architectures:

```powershell
# For x64, x86, and ARM64
foreach ($platform in @("x64", "x86", "arm64")) {
    msbuild Files.slnx `
      -t:Restore,Build `
      -p:Configuration=Release `
      -p:Platform=$platform
}
```

### Step 5: Create the MSIX Package

The MSIX package is created during the build. Look for it in:

```
bin/Release/x64/publish/
```

Or using the publish script:

```powershell
msbuild src/Files.App/Files.App.csproj `
  -t:Publish `
  -p:Configuration=Release `
  -p:Platform=x64 `
  -p:PublishProfile=Properties/PublishProfiles/win-x64.pubxml
```

### Step 6: Create a Self-Signed Certificate (for Sideload)

To install the MSIX package, you need to sign it with a self-signed certificate:

```powershell
# Run this PowerShell script to generate a certificate
$CertName = "FilesCommunity"
$CertPassword = ConvertTo-SecureString -String "password" -Force -AsPlainText

$cert = New-SelfSignedCertificate `
  -Type CodeSigningCert `
  -Subject "CN=$CertName" `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")

Export-PfxCertificate `
  -Cert $cert `
  -FilePath "FilesCommunity.pfx" `
  -Password $CertPassword

# Add the certificate to trusted root store
Import-PfxCertificate `
  -FilePath "FilesCommunity.pfx" `
  -CertStoreLocation "Cert:\CurrentUser\Root" `
  -Password $CertPassword
```

### Step 7: Install the MSIX Package

#### Option A: Using PowerShell

```powershell
Add-AppxPackage -Path "bin/Release/x64/publish/Files.msix"
```

#### Option B: Double-click the MSIX file in File Explorer

Navigate to the MSIX file location and double-click it to launch the installer.

#### Option C: Using Windows App Installer

Right-click the MSIX file → "Install with App Installer"

## Build Artifacts

After building, you'll find:

- **MSIX Package**: `bin/Release/x64/publish/Files.msix` (single architecture)
- **App Bundle**: `bin/Release/x64/publish/Files.msixbundle` (multiple architectures)
- **Executable**: `bin/Release/x64/publish/Files.exe`

## Environment Configuration

The build automatically uses the **Dev** environment if no specific build configuration is set. To explicitly set the environment:

Edit `Directory.Build.props` or use MSBuild property:

```powershell
msbuild Files.slnx `
  -p:AppEnvironment=SideloadStable `
  -p:Configuration=Release `
  -p:Platform=x64
```

## Removing Store Integration (Optional)

The sideload version automatically excludes Store-specific features. If you want to further customize:

1. Search for `StoreStable` or `StorePreview` in the codebase to find Store-specific code
2. The app uses conditional compilation based on `AppEnvironment`
3. Store reviews/ratings are only shown for Store builds

## Troubleshooting

### Error: "The project file may be invalid or missing targets required for restore"

This error occurs when building on non-Windows systems. You must build on Windows.

### Error: "NETSDK1100: To build a project targeting Windows on this operating system, set the EnableWindowsTargeting property to true"

You are trying to build on a non-Windows system. This app can only be built on Windows.

### Error: "Certificate not trusted"

Ensure your self-signed certificate is installed in the Windows Trusted Root certificate store.

### Error: "Package name cannot contain the following characters: <, >, :, /, \, |, ?, *"

The package name in `Package.appxmanifest` contains invalid characters. Edit and fix the name.

## Additional Resources

- **Files GitHub**: https://github.com/muko-git/Files
- **Windows App SDK**: https://github.com/microsoft/WindowsAppSDK
- **MSIX Documentation**: https://docs.microsoft.com/windows/msix/

## License

Files is licensed under the MIT License. You are free to build and distribute it as allowed by the license.
