# Quick Start Guide - Files App Without Paywall

## TL;DR

The **Files app is free to build from source**. Follow these steps on Windows:

```powershell
# 1. Clone/navigate to the Files repository
cd C:\path\to\Files

# 2. Build the sideload version
.\Build-FilesSideload.ps1

# 3. Install it
.\Install-Files.ps1

# Done! Files is now installed, free of any paywall.
```

---

## What This Means

✅ **Free** - No Microsoft Store purchase required  
✅ **Same app** - Identical to the paid Store version  
✅ **Open source** - MIT licensed, fully auditable  
✅ **Full features** - Everything the Store version has  

---

## How It Works

The Files app source code is open-source. Instead of buying it from Microsoft Store ($4.99), you:

1. **Build it** from the source code (included here)
2. **Package it** as an MSIX (Windows app format)
3. **Install it** locally on your Windows machine
4. **Use it** with no limitations

This is 100% legal and supported by the MIT License.

---

## Requirements

- **Operating System:** Windows 10/11
- **Visual Studio 2022** or Build Tools 2022
- **.NET SDK 10.0+**

**Not on Windows?** These tools only work on Windows. You'll need a Windows machine to build.

---

## Step-by-Step

### Step 1: Prerequisites
Ensure you have the required tools installed:
- Visual Studio 2022 (with C++/C# workloads)
- .NET SDK 10.0+

### Step 2: Open PowerShell
Open PowerShell as Administrator and navigate to the Files repository:

```powershell
cd C:\path\to\Files
```

### Step 3: Build
Run the build script:

```powershell
.\Build-FilesSideload.ps1
```

This will:
- ✓ Restore dependencies
- ✓ Compile the app
- ✓ Package it as MSIX
- ✓ Generate a certificate

Takes 5-10 minutes depending on your machine.

### Step 4: Install
Run the install script:

```powershell
.\Install-Files.ps1
```

This will:
- ✓ Find the built MSIX
- ✓ Install it locally
- ✓ Launch it

Done! 🎉

---

## After Installation

You can now:

- ✓ Launch from Start Menu → "Files"
- ✓ Use all features
- ✓ Pin to taskbar
- ✓ Set as default file manager
- ✓ Uninstall anytime via Settings

---

## Troubleshooting

### "Permission denied" or PowerShell errors
- Right-click PowerShell → "Run as administrator"
- Or: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### "Visual Studio not found"
- Install Visual Studio 2022 from https://visualstudio.microsoft.com/
- Include C++ and .NET workloads

### "MSIX file not found"
- Build completed but scripts couldn't find the MSIX
- Check `bin/Release/x64/publish/` manually
- Or run with specific platform: `.\Build-FilesSideload.ps1 -Platform x64`

### "Certificate not trusted"
- The self-signed certificate needs trust
- Usually handled automatically
- If issues persist, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)

---

## Advanced Options

### Build for specific architecture

```powershell
# 32-bit
.\Build-FilesSideload.ps1 -Platform x86

# ARM64 (for new Surface devices)
.\Build-FilesSideload.ps1 -Platform arm64
```

### Build with Debug information

```powershell
.\Build-FilesSideload.ps1 -Configuration Debug
```

### Manual installation

```powershell
Add-AppxPackage -Path "C:\path\to\Files.msix"
```

---

## Uninstall

```powershell
Get-AppxPackage -Name "FilesDev" | Remove-AppxPackage
```

Or via Settings → Apps → Installed apps → Search "Files" → Uninstall

---

## Is This Legal?

**Yes, 100% legal.**

- Files is MIT licensed
- You have the right to build from source
- You have the right to install locally
- You have the right to use it

The only restriction is you can't redistribute commercially.

---

## What's Different from Store Version?

**Functionally:** Nothing. Same features, same performance.

**Technically:**
- Uses `SideloadStable` build environment (vs `StoreStable`)
- No Store update service (you update manually by rebuilding)
- No Store review prompts (you don't need them)
- Self-signed certificate instead of Store certificate

---

## Distribution

Once built, you can share the MSIX file with others:

```powershell
# Share: C:\path\to\Files\bin\Release\x64\publish\Files.msix

# Others can install with:
Add-AppxPackage -Path "C:\path\to\Files.msix"
```

---

## Next Steps

1. ✅ Read [SIDELOAD_BUILD.md](SIDELOAD_BUILD.md) for more details
2. ✅ Read [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for complete reference
3. ✅ Run `.\Build-FilesSideload.ps1` to start building
4. ✅ Run `.\Install-Files.ps1` to install

---

## Questions?

- Check the [Files GitHub Issues](https://github.com/muko-git/Files/issues)
- See [Files GitHub Discussions](https://github.com/muko-git/Files/discussions)

**Enjoy your free, open-source Files app! 🚀**
