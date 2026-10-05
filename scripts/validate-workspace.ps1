[CmdletBinding()]
param(
    [string]$WorkspaceRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$root = [System.IO.Path]::GetFullPath($WorkspaceRoot)
$errors = [System.Collections.Generic.List[string]]::new()
$registryPath = Join-Path $root 'mc-plan-foundation/memory/current/repositories.json'
$registry = $null
$repositories = @()

try {
    $registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json -Depth 100
    $repositories = @($registry.repositories | Where-Object { $_.lifecycle -eq 'active' })
}
catch {
    $errors.Add("Cannot load repository registry: $($_.Exception.Message)")
}

if (Test-Path -LiteralPath (Join-Path $root '.git')) {
    $errors.Add('Workspace root must not be a Git repository.')
}

foreach ($repository in $repositories) {
    $path = Join-Path $root ([string]$repository.path)
    foreach ($required in @('README.md', 'AGENTS.md', 'LICENSE')) {
        if (-not (Test-Path -LiteralPath (Join-Path $path $required))) {
            $errors.Add("$($repository.name) is missing $required")
        }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $path 'docs/STATUS.md'))) {
        $errors.Add("$($repository.name) is missing docs/STATUS.md")
    }
    if ($registry.coordination_ready -eq $true -and -not (Test-Path -LiteralPath (Join-Path $path 'docs/development-plan.md'))) {
        $errors.Add("$($repository.name) is missing docs/development-plan.md")
    }
}

$registeredPaths = @($registry.repositories | ForEach-Object { [string]$_.path })
foreach ($directory in (Get-ChildItem -LiteralPath $root -Directory -Filter 'mc-plan-*')) {
    if ($registeredPaths -notcontains $directory.Name) {
        $errors.Add("Unregistered MC Plan directory: $($directory.Name)")
    }
}

. (Join-Path $PSScriptRoot 'get-project-files.ps1')
$projectFiles = @{}
foreach ($repository in $repositories) {
    try {
        $projectFiles[[string]$repository.name] = @(Get-ProjectFiles -RepositoryPath (Join-Path $root ([string]$repository.path)))
    }
    catch { $errors.Add($_.Exception.Message) }
}
$markdownFiles = @($projectFiles.Values | ForEach-Object { $_ } | Where-Object { $_.Extension -eq '.md' })

foreach ($file in $markdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value.Trim().Trim('<', '>')
        if ($target -match '^(https?://|mailto:|#|codex:)') { continue }
        $targetPath = ($target -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }
        $resolved = Join-Path $file.DirectoryName ([Uri]::UnescapeDataString($targetPath))
        if (-not (Test-Path -LiteralPath $resolved)) {
            $relativeFile = [System.IO.Path]::GetRelativePath($root, $file.FullName)
            $errors.Add("Broken local link in ${relativeFile}: $target")
        }
    }
}

$jsonFiles = @(
    foreach ($name in @('mc-plan-contracts', 'mc-plan-foundation')) {
        $projectFiles[$name] | Where-Object { $_.Extension -eq '.json' }
    }
)
$schemaIds = @{}
foreach ($file in $jsonFiles) {
    try {
        $document = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -Depth 100
        if ($null -ne $document.'$id') {
            $id = [string]$document.'$id'
            if ($schemaIds.ContainsKey($id)) {
                $errors.Add("Duplicate JSON Schema id: $id")
            }
            else {
                $schemaIds[$id] = $file.FullName
            }
        }
    }
    catch {
        $errors.Add("Invalid JSON: $($file.FullName): $($_.Exception.Message)")
    }
}

$contractFiles = $projectFiles['mc-plan-contracts'] |
    Where-Object { $_.Extension -in @('.json', '.yaml', '.yml') }
foreach ($file in $contractFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($content, '(?m)(?:"?\$ref"?\s*:\s*"?)(\.\.?/[^"\s#]+)')) {
        $reference = $match.Groups[1].Value
        $resolved = Join-Path $file.DirectoryName $reference
        if (-not (Test-Path -LiteralPath $resolved)) {
            $relativeFile = [System.IO.Path]::GetRelativePath($root, $file.FullName)
            $errors.Add("Missing local contract reference in ${relativeFile}: $reference")
        }
    }
}

$expectedSkills = @('mc-plan-development', 'mc-plan-orchestrator')
foreach ($skillName in $expectedSkills) {
    $skillRoot = Join-Path $root "mc-plan-foundation/.codex/skills/$skillName"
    $skill = Join-Path $skillRoot 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skill)) {
        $errors.Add("$skillName SKILL.md is missing.")
        continue
    }

    $skillText = Get-Content -LiteralPath $skill -Raw
    $escapedSkillName = [regex]::Escape($skillName)
    if ($skillText -notmatch "(?m)^name:\s+$escapedSkillName\s*$") {
        $errors.Add("$skillName frontmatter name is missing or invalid.")
    }
    if ($skillText -notmatch '(?m)^description:\s+\S+') {
        $errors.Add("$skillName frontmatter description is missing.")
    }

    foreach ($requiredSkillFile in @('VERSION', 'agents/openai.yaml', 'scripts/install.ps1')) {
        if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $requiredSkillFile))) {
            $errors.Add("$skillName is missing $requiredSkillFile.")
        }
    }
}

$coordinationValidator = Join-Path $root 'mc-plan-foundation/scripts/validate-coordination.ps1'
if (Test-Path -LiteralPath $coordinationValidator) {
    try {
        & $coordinationValidator -WorkspaceRoot $root | Out-Null
    }
    catch {
        $errors.Add("Coordination validation failed: $($_.Exception.Message)")
    }
}
else {
    $errors.Add('Coordination validator is missing.')
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Workspace validation failed with $($errors.Count) error(s)."
}

Write-Output "Workspace validation passed for $($repositories.Count) active repositories, $($markdownFiles.Count) Markdown files, and $($jsonFiles.Count) JSON files."
