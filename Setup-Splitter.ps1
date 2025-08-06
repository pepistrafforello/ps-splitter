<#
.DESCRIPTION
    File Splitter setup script
.NOTES
    Author: giuseppe.strafforello@titantechnologies.com
    Version: 1.0
    Requires: PowerShell 3.0 or higher
    Copyright (C) 2025 Titan Technologies. All rights reserved.
    This script is licensed under the Apache License, Version 2.0.
#>

# Run as Administrator
try {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $adminRole.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as an administrator."
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

try {
    $ModulePath = "C:\Program Files\WindowsPowerShell\Modules\FileSplitter"
    New-Item -ItemType Directory -Path $ModulePath -Force
    Copy-Item "Split-File.ps1" $ModulePath
    New-ModuleManifest -Path "$ModulePath\FileSplitter.psd1" -RootModule "Split-File.ps1" -Description "File splitting utility"

    Write-Host "FileSplitter module installed to $ModulePath" -ForegroundColor Green
    Write-Host "You can now use the Split-File cmdlet to split files." -ForegroundColor Green
    Write-Host "Run 'Import-Module FileSplitter' to use the cmdlet in your current session." -ForegroundColor Green
    Write-Host "To make it permanent, add 'Import-Module FileSplitter' to your PowerShell profile." -ForegroundColor Green
    Write-Host "Example usage: Split-File -InputFile 'C:\path\to\your\file.txt' -ChunkSize '100MB' -OutputDirectory 'C:\path\to\output'" -ForegroundColor Green
} catch {
    Write-Error "Failed to set up FileSplitter module: $_"
    exit 1
}