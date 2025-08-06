<#
.SYNOPSIS
    Splits a binary file into smaller chunks of specified size.

.DESCRIPTION
    This script reads a binary file and splits it into smaller chunks of a specified size.
    Each chunk is saved as a separate file in the output directory with sequential naming.

.PARAMETER InputFile
    The path to the input file that will be split into chunks.
    This parameter is mandatory.

.PARAMETER OutputDirectory
    The directory where the split chunks will be saved.
    If not specified, defaults to the same directory as the input file with "_chunks" suffix.

.PARAMETER ChunkSize
    The size of each chunk. Supports units like KB, MB, GB.
    Default is 1MB. Examples: 512KB, 2MB, 1GB

.PARAMETER ChunkPrefix
    The prefix for the output chunk files.
    Default is "chunk_". Files will be named like "chunk_0001.bin"

.PARAMETER Overwrite
    If specified, existing chunk files in the output directory will be overwritten.
    Otherwise, the script will prompt for confirmation.

.PARAMETER Quiet
    Suppresses progress output. Only errors and final results will be displayed.

.EXAMPLE
    .\Split-File.ps1 -InputFile "C:\data\largefile.bin" -ChunkSize 2MB
    
    Splits largefile.bin into 2MB chunks in the default output directory.

.EXAMPLE
    .\Split-File.ps1 -InputFile "data.zip" -OutputDirectory "C:\chunks" -ChunkSize 512KB -ChunkPrefix "part_"
    
    Splits data.zip into 512KB chunks in C:\chunks directory with "part_" prefix.

.EXAMPLE
    .\Split-File.ps1 -InputFile "archive.tar" -ChunkSize 1GB -Overwrite -Quiet
    
    Splits archive.tar into 1GB chunks, overwriting existing files without prompting, with minimal output.

.NOTES
    Author: giuseppe.strafforello@titantechnologies.com
    Version: 1.0
    Requires: PowerShell 3.0 or higher
    Copyright (C) 2025 Titan Technologies. All rights reserved.
    This script is licensed under the Apache License, Version 2.0.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Path to the input file to split")]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Leaf)) {
            throw "Input file '$_' does not exist or is not a file."
        }
        $true
    })]
    [string]$InputFile,

    [Parameter(HelpMessage = "Output directory for chunk files")]
    [string]$OutputDirectory,

    [Parameter(HelpMessage = "Size of each chunk (supports KB, MB, GB units)")]
    [ValidateScript({
        if ($_ -match '^\d+(\.\d+)?\s*(KB|MB|GB|B)?$') {
            $true
        } else {
            throw "Invalid chunk size format. Use format like '1MB', '512KB', '2GB', or just a number for bytes."
        }
    })]
    [string]$ChunkSize = "1MB",

    [Parameter(HelpMessage = "Prefix for output chunk files")]
    [ValidatePattern('^[a-zA-Z0-9_-]+$')]
    [string]$ChunkPrefix = "chunk_",

    [Parameter(HelpMessage = "Overwrite existing chunk files without prompting")]
    [switch]$Overwrite,

    [Parameter(HelpMessage = "Suppress progress output")]
    [switch]$Quiet
)

# Function to convert size string to bytes
function ConvertTo-Bytes {
    param([string]$SizeString)
    
    $SizeString = $SizeString.Trim().ToUpper()
    
    if ($SizeString -match '^(\d+(?:\.\d+)?)\s*(KB|MB|GB|B)?$') {
        $number = [double]$matches[1]
        $unit = $matches[2]
        
        switch ($unit) {
            'KB' { return [long]($number * 1KB) }
            'MB' { return [long]($number * 1MB) }
            'GB' { return [long]($number * 1GB) }
            'B'  { return [long]$number }
            default { return [long]$number }  # No unit specified, assume bytes
        }
    }
    
    throw "Invalid size format: $SizeString"
}

# Function to format bytes for display
function Format-Bytes {
    param([long]$Bytes)
    
    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    } elseif ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    } elseif ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    } else {
        return "$Bytes bytes"
    }
}

try {
    # Resolve full path for input file
    $InputFile = Resolve-Path $InputFile -ErrorAction Stop
    
    # Set default output directory if not specified
    if (-not $OutputDirectory) {
        $inputDir = Split-Path $InputFile -Parent
        $inputName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
        $OutputDirectory = Join-Path $inputDir "${inputName}_chunks"
    }

    # Ensure the output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        if (-not $Quiet) {
            Write-Host "Creating output directory: $OutputDirectory" -ForegroundColor Yellow
        }
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    # Convert chunk size to bytes
    $chunkSizeBytes = ConvertTo-Bytes $ChunkSize
    
    # Get input file info
    $fileInfo = Get-Item $InputFile
    $totalSize = $fileInfo.Length
    
    if (-not $Quiet) {
        Write-Host "Input file: $InputFile" -ForegroundColor Green
        Write-Host "File size: $(Format-Bytes $totalSize)" -ForegroundColor Green
        Write-Host "Chunk size: $(Format-Bytes $chunkSizeBytes)" -ForegroundColor Green
        Write-Host "Output directory: $OutputDirectory" -ForegroundColor Green
        Write-Host ""
    }

    # Check if output directory has existing chunk files
    $existingChunks = Get-ChildItem -Path $OutputDirectory -Filter "${ChunkPrefix}*.bin" -ErrorAction SilentlyContinue
    if ($existingChunks -and -not $Overwrite) {
        $response = Read-Host "Output directory contains existing chunk files. Continue? [Y/N]"
        if ($response -notmatch '^[Yy]') {
            Write-Host "Operation cancelled by user." -ForegroundColor Yellow
            exit 0
        }
    }

    # Open the input file for reading
    $inputStream = [System.IO.File]::OpenRead($InputFile)
    
    try {
        $buffer = New-Object byte[] $chunkSizeBytes
        $chunkIndex = 0
        $totalBytesProcessed = 0

        while (($bytesRead = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            # Define the output file name
            $outputFile = Join-Path $OutputDirectory ("{0}{1:D4}.bin" -f $ChunkPrefix, $chunkIndex)

            # Write the chunk to the output file
            if ($bytesRead -eq $buffer.Length) {
                [System.IO.File]::WriteAllBytes($outputFile, $buffer)
            } else {
                # Last chunk might be smaller
                $lastChunkBuffer = New-Object byte[] $bytesRead
                [Array]::Copy($buffer, $lastChunkBuffer, $bytesRead)
                [System.IO.File]::WriteAllBytes($outputFile, $lastChunkBuffer)
            }

            $totalBytesProcessed += $bytesRead
            $chunkIndex++

            # Show progress
            if (-not $Quiet) {
                $percentComplete = [math]::Round(($totalBytesProcessed / $totalSize) * 100, 1)
                Write-Progress -Activity "Splitting file" -Status "Processing chunk $chunkIndex" -PercentComplete $percentComplete
            }
        }

        if (-not $Quiet) {
            Write-Progress -Activity "Splitting file" -Completed
            Write-Host ""
            Write-Host "✓ File successfully split into $chunkIndex chunks." -ForegroundColor Green
            Write-Host "Total size processed: $(Format-Bytes $totalBytesProcessed)" -ForegroundColor Green
            Write-Host "Output location: $OutputDirectory" -ForegroundColor Green
        } else {
            Write-Host "Split complete: $chunkIndex chunks created in $OutputDirectory"
        }

    } finally {
        # Close the input stream
        $inputStream.Close()
    }

} catch {
    Write-Error 'An error occurred: $($_.Exception.Message)'
    exit 1
}