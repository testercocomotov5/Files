# Files App - Sideload Build (No Paywall)

This guide explains how to build and use the **Files app for Windows without the Microsoft Store paywall**.

## What You Need to Know

The Files app is available for purchase on the Microsoft Store. However, since the app is open-source (MIT License), you can build it yourself for free and install it as a sideload application on Windows.

**No paywall means:**
- ✓ Free to build from source
- ✓ Free to install on your Windows machine
- ✓ Full access to all features
- ✓ Fully open-source and auditable

## Quick Start (Windows Only)

### Prerequisites
- Windows 10/11
- [Visual Studio 2022](https://visualstudio.microsoft.com/) or [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
- [.NET SDK 10.0+](https://dotnet.microsoft.com/download)

### Build & Install

```powershell
# 1. Navigate to the Files repository
cd C:\path\to\Files

# 2. Run the build script
.\Build-FilesSideload.ps1

# 3. Install the app
.\Install-Files.ps1
```

That's it! Files is now installed on your machine without any paywall.

## Detailed Build Instructions

For detailed step-by-step instructions, see [BUILD_INSTRUCTIONS.md](./BUILD_INSTRUCTIONS.md)

## Why Sideload vs. Microsoft Store?

| Aspect | Sideload (This) | Microsoft Store |
|--------|---|---|
| Cost | Free ✓ | Paid |
| Source | Open-source ✓ | Same source |
| Updates | Manual | Automatic |
| Installation | Local | Via Store app |
| Features | All | All |
| Support | Community | Official |

## Understanding "Without Paywall"

The Files app has two versions available:

1. **Microsoft Store Version** - Paid distribution
   - Built with `StoreStable` environment
   - Includes Store integration (reviews, ratings, etc.)
   - Requires purchase

2. **Sideload Version** - Free (this build)
   - Built with `SideloadStable` or `Dev` environment
   - No Store integration needed
   - Can be built and installed locally
   - Identical features to Store version

This build creates option #2, allowing you to use the app without paying.

## What's Different?

**Functionally:** Nothing. The sideload version has the exact same features as the Store version.

**Technically:** 
- No Store licensing checks
- No Store update service (manual updates instead)
- No Store review/rating prompts
- Uses a self-signed certificate for installation

## Build Environments Explained

The Files app source code supports multiple build environments:

```
Dev                  → Development build (auto-updating version)
SideloadStable      → Stable sideload version (recommended) ✓
SideloadPreview     → Preview sideload version
StoreStable         → Microsoft Store stable (paid)
StorePreview        → Microsoft Store preview (paid)
```

The scripts use **`SideloadStable`** by default, which is the recommended option.

## File Locations After Build

After running the build script, you'll find:

```
Files/
├── bin/
│   └── Release/
│       ├── x64/publish/Files.msix       (64-bit package)
│       ├── x86/publish/Files.msix       (32-bit package)
│       └── arm64/publish/Files.msix     (ARM64 package)
├── Build-FilesSideload.ps1              (Build script)
└── Install-Files.ps1                    (Install script)
```

## Installing on Multiple Machines

Once built, you can share the MSIX file:

```powershell
# On another Windows machine:
Add-AppxPackage -Path "C:\Path\To\Files.msix"
```

**Important:** The receiving machine must trust the certificate used to sign the MSIX.

## Uninstalling

```powershell
# Remove via PowerShell
Get-AppxPackage -Name "FilesDev" | Remove-AppxPackage

# Or via Settings:
Settings → Apps → Installed Apps → Search "Files" → Uninstall
```

## Troubleshooting

### "Certificate not trusted"

The self-signed certificate needs to be trusted:

```powershell
# Install the certificate to trusted root
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -like "*FilesCommunity*" }
Export-PfxCertificate -Cert $cert -FilePath cert.pfx -Password (ConvertTo-SecureString -String "password" -AsPlainText -Force)
Import-PfxCertificate -FilePath cert.pfx -CertStoreLocation "Cert:\CurrentUser\Root"
```

### "App won't launch"

Try reinstalling:

```powershell
Get-AppxPackage -Name "FilesDev" | Remove-AppxPackage
Add-AppxPackage -Path ".\bin\Release\x64\publish\Files.msix"
```

### Build fails on non-Windows OS

This app can only be built on Windows. Linux and macOS are not supported for building.

## Contributing

If you find issues or want to improve the app:

1. Fork the [Files repository](https://github.com/muko-git/Files)
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Files is licensed under the **MIT License** - see [LICENSE](./LICENSE) file.

## Support

- **GitHub Issues:** https://github.com/muko-git/Files/issues
- **GitHub Discussions:** https://github.com/muko-git/Files/discussions

## Related Resources

- [Files GitHub Repository](https://github.com/muko-git/Files)
- [Windows App SDK Documentation](https://docs.microsoft.com/windows/apps/windows-app-sdk/)
- [MSIX Packaging Overview](https://docs.microsoft.com/windows/msix/)
- [MIT License](https://opensource.org/licenses/MIT)
