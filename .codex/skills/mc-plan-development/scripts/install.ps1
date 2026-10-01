[CmdletBinding()]
param(
    [string]$DestinationRoot,
    [switch]$Replace,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
$skillName = 'mc-plan-development'
$skillSource = Split-Path -Parent $PSScriptRoot

if ($Replace -and $Check) {
    throw '-Replace and -Check cannot be used together.'
}

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $DestinationRoot = $env:CODEX_HOME
    }
    else {
        $DestinationRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
}

function Get-SkillManifest {
    param([string]$Root)

    $textExtensions = @(
        '', '.bat', '.cfg', '.cmd', '.csv', '.ini', '.js', '.json', '.md',
        '.ps1', '.py', '.sh', '.toml', '.ts', '.txt', '.xml', '.yaml', '.yml'
    )
    $entries = [System.Collections.Generic.List[string]]::new()
    foreach ($file in (Get-ChildItem -LiteralPath $Root -Recurse -File | Sort-Object FullName)) {
        $relative = [System.IO.Path]::GetRelativePath($Root, $file.FullName).Replace('\', '/')
        if ($textExtensions -contains $file.Extension.ToLowerInvariant()) {
            $text = [System.IO.File]::ReadAllText($file.FullName)
            $normalized = $text.Replace("`r`n", "`n").Replace("`r", "`n")
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
            $hashBytes = [System.Security.Cryptography.SHA256]::HashData($bytes)
            $hash = [Convert]::ToHexString($hashBytes).ToLowerInvariant()
        }
        else {
            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
        $entries.Add("$relative=$hash")
    }
    return @($entries)
}

$destinationRootFull = [System.IO.Path]::GetFullPath($DestinationRoot)
$skillsDirectory = Join-Path $destinationRootFull 'skills'
$target = Join-Path $skillsDirectory $skillName

if ($Check) {
    if (-not (Test-Path -LiteralPath $target)) {
        throw "Skill is not installed at $target"
    }
    $difference = @(Compare-Object (Get-SkillManifest $skillSource) (Get-SkillManifest $target))
    if ($difference.Count -ne 0) {
        throw "Installed $skillName is stale. Run this canonical installer with -Replace."
    }
    $version = (Get-Content -LiteralPath (Join-Path $target 'VERSION') -Raw).Trim()
    Write-Output "$skillName $version is current at $target"
    exit 0
}

if (Test-Path -LiteralPath $target) {
    if (-not $Replace) {
        throw "Skill already exists at $target. Re-run with -Replace to preserve it as a timestamped backup and install this version."
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmssfff'
    $backup = "$target.backup-$timestamp"
    Move-Item -LiteralPath $target -Destination $backup
    Write-Output "Previous skill moved to $backup"
}

New-Item -ItemType Directory -Path $skillsDirectory -Force | Out-Null
Copy-Item -LiteralPath $skillSource -Destination $target -Recurse

$difference = @(Compare-Object (Get-SkillManifest $skillSource) (Get-SkillManifest $target))
if ($difference.Count -ne 0) {
    throw "Installation failed: $target does not match the authoritative source."
}

$version = (Get-Content -LiteralPath (Join-Path $target 'VERSION') -Raw).Trim()
Write-Output "Installed $skillName $version at $target"
