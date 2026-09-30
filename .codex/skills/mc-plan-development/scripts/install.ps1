[CmdletBinding()]
param(
    [string]$DestinationRoot,
    [switch]$Replace
)

$ErrorActionPreference = 'Stop'
$skillName = 'mc-plan-development'
$skillSource = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $DestinationRoot = $env:CODEX_HOME
    }
    else {
        $DestinationRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
}

$destinationRootFull = [System.IO.Path]::GetFullPath($DestinationRoot)
$skillsDirectory = Join-Path $destinationRootFull 'skills'
$target = Join-Path $skillsDirectory $skillName

if (Test-Path -LiteralPath $target) {
    if (-not $Replace) {
        throw "Skill already exists at $target. Re-run with -Replace to preserve it as a timestamped backup and install this version."
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backup = "$target.backup-$timestamp"
    Move-Item -LiteralPath $target -Destination $backup
    Write-Output "Previous skill moved to $backup"
}

New-Item -ItemType Directory -Path $skillsDirectory -Force | Out-Null
Copy-Item -LiteralPath $skillSource -Destination $target -Recurse

if (-not (Test-Path -LiteralPath (Join-Path $target 'SKILL.md'))) {
    throw "Installation failed: SKILL.md is missing at $target"
}

Write-Output "Installed $skillName at $target"
