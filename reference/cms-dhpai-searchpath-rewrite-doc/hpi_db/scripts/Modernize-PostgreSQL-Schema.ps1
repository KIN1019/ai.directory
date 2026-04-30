#!/usr/bin/env pwsh
<#
.SYNOPSIS
    PostgreSQL Schema Modernization Script

.DESCRIPTION
    This script runs the PostgreSQL schema modernization tool to replace
    SET search_path statements with explicit schema prefixes.

.PARAMETER InputDir
    The input directory containing the hpi_db folder

.PARAMETER OutputDir
    The output directory for modernized files (optional, defaults to input dir)

.PARAMETER ReportFile
    The name of the report file (optional, defaults to modernization_report.md)

.PARAMETER WhatIf
    Preview mode - shows what would be changed without making changes

.EXAMPLE
    .\Modernize-PostgreSQL-Schema.ps1 -InputDir "C:\Workspace\development\dhp-ai-package\pas-schema-tool\v302"

.EXAMPLE
    .\Modernize-PostgreSQL-Schema.ps1 -InputDir "C:\path\to\input" -OutputDir "C:\path\to\output" -WhatIf
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir,

    [Parameter(Mandatory = $false)]
    [string]$ReportFile = "modernization_report.md",

    [switch]$WhatIf
)

# Ensure input directory exists
if (-not (Test-Path $InputDir)) {
    Write-Error "Input directory does not exist: $InputDir"
    exit 1
}

# Check if hpi_db exists in input directory
$HpiDbPath = Join-Path $InputDir "hpi_db"
if (-not (Test-Path $HpiDbPath)) {
    Write-Error "hpi_db directory not found in: $InputDir"
    exit 1
}

# Set output directory
if (-not $OutputDir) {
    $OutputDir = $InputDir
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "pg_schema_modernizer.py"
$RequirementsFile = Join-Path $ScriptDir "requirements.txt"

# Check if Python script exists
if (-not (Test-Path $PythonScript)) {
    Write-Error "Python script not found: $PythonScript"
    exit 1
}

# Check Python installation
try {
    $pythonVersion = python --version 2>$null
    if (-not $pythonVersion) {
        $pythonVersion = python3 --version 2>$null
    }
    if (-not $pythonVersion) {
        Write-Error "Python is not installed or not in PATH"
        exit 1
    }
    Write-Host "Using Python: $pythonVersion"
} catch {
    Write-Error "Python is not installed or not in PATH"
    exit 1
}

# Install dependencies if requirements.txt exists
if (Test-Path $RequirementsFile) {
    Write-Host "Installing Python dependencies..."
    try {
        pip install -r $RequirementsFile
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install dependencies. Continuing anyway..."
        }
    } catch {
        Write-Warning "Failed to install dependencies. Continuing anyway..."
    }
}

# Build command arguments
$arguments = @(
    $PythonScript,
    "--input-dir", $InputDir,
    "--output-dir", $OutputDir,
    "--report-file", $ReportFile
)

if ($WhatIf) {
    Write-Host "WHATIF MODE: Previewing changes without making modifications"
    # Note: The Python script doesn't have a --whatif flag yet, so we'll just show the command
    $arguments += @("--verbose")
}

# Run the Python script
Write-Host "Starting PostgreSQL schema modernization..."
Write-Host "Command: python $($arguments -join ' ')"

try {
    if ($WhatIf) {
        Write-Host "Preview mode - would run: python $($arguments -join ' ')"
        Write-Host "Report would be generated at: $(Join-Path $OutputDir $ReportFile)"
    } else {
        & python @arguments

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Schema modernization completed successfully!"
            Write-Host "Report generated at: $(Join-Path $OutputDir $ReportFile)"
        } else {
            Write-Error "Schema modernization failed with exit code: $LASTEXITCODE"
            exit $LASTEXITCODE
        }
    }
} catch {
    Write-Error "Failed to run schema modernization: $_"
    exit 1
}