<#
.SYNOPSIS
    Installs uv, the Python package and project manager, on Windows.

.DESCRIPTION
    Runs Astral's official standalone installer
    (https://docs.astral.sh/uv/getting-started/installation/), which puts uv.exe
    in %USERPROFILE%\.local\bin and adds that directory to the user PATH.
    Does nothing if uv is already installed; update an existing installation
    with `uv self update`.

    The installer honours the UV_INSTALL_DIR, UV_NO_MODIFY_PATH and
    UV_UNMANAGED_INSTALL environment variables.

.PARAMETER Version
    The uv version to install, for example 0.12.18. Defaults to the latest
    release.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install-uv.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install-uv.ps1 -Version 0.12.18
#>
[CmdletBinding()]
param(
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string] $Version
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$existing = Get-Command uv -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "uv is already installed: $(& uv --version) ($($existing.Source))"
    Write-Host 'Update it with: uv self update'
    return
}

if ($Version) {
    $url = "https://astral.sh/uv/$Version/install.ps1"
} else {
    $url = 'https://astral.sh/uv/install.ps1'
}
Write-Host "Installing uv with the official installer: $url"

# Run the installer exactly as Astral documents it, in a child PowerShell
# process, so its execution policy and exit code cannot affect this script.
$powershell = (Get-Process -Id $PID).Path
& $powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-RestMethod '$url' | Invoke-Expression"
if ($LASTEXITCODE -ne 0) {
    throw "The uv installer failed with exit code $LASTEXITCODE."
}

# The installer changes PATH for new terminals only. Extend the PATH of this
# session so the installation can be checked right away.
$candidates = @($env:UV_UNMANAGED_INSTALL, $env:UV_INSTALL_DIR, $env:XDG_BIN_HOME, (Join-Path $HOME '.local\bin'))
foreach ($dir in $candidates) {
    if ($dir -and (Test-Path -LiteralPath (Join-Path $dir 'uv.exe'))) {
        $env:Path = "$dir;$env:Path"
        break
    }
}
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw 'uv was installed, but uv.exe was not found in the expected directories.'
}

Write-Host "Installed $(& uv --version)."
Write-Host 'Open a new terminal so uv is on your PATH, then run: uv sync'
