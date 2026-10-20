[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [string]$ManifestPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'migration/windows-20261020.json'),
    [switch]$InstallSkills
)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PowerShell 7 is required.' }
Get-Command git -ErrorAction Stop | Out-Null
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json -Depth 100
if ($manifest.schema_version -ne 1) { throw 'Unsupported migration manifest.' }
$root = [System.IO.Path]::GetFullPath($WorkspaceRoot)
[System.IO.Directory]::CreateDirectory($root) | Out-Null
# Transport only. Never reset, clean, stash, overwrite or switch an existing checkout.
foreach ($repo in $manifest.repositories) {
    if ($repo.name -notmatch '^mc-plan-[a-z]+$' -or $repo.checkpoint -notmatch '^[0-9a-f]{40}$' -or
        $repo.url -notmatch '^https://github\.com/chenfengyimei/mc-plan-[a-z]+\.git$' -or
        [string]::IsNullOrWhiteSpace($repo.branch) -or $repo.branch.StartsWith('-')) {
        throw 'Invalid repository entry in the manifest.'
    }
    $path = Join-Path $root $repo.name
    if (-not (Test-Path -LiteralPath $path)) {
        & git clone --branch $repo.branch -- $repo.url $path
    }
    if (-not (Test-Path -LiteralPath (Join-Path $path '.git'))) { throw "Not a Git checkout: $path" }
    $actualUrl = (& git -C $path remote get-url origin).Trim()
    if ($actualUrl -cne $repo.url) { throw "Origin differs at $path; inspect it manually." }
    if (@(& git -C $path status --porcelain=v1 --untracked-files=all).Count -ne 0) {
        throw "Dirty checkout retained at $path; reconcile before restoring."
    }
    $actualBranch = (& git -C $path branch --show-current).Trim()
    if ($actualBranch -cne $repo.branch) { throw "Branch differs at $path; expected $($repo.branch)." }
    $head = (& git -C $path rev-parse HEAD).Trim()
    if ($repo.allow_descendant -eq $true) {
        & git -C $path merge-base --is-ancestor $repo.checkpoint HEAD
    }
    elseif ($head -cne $repo.checkpoint) { throw "Checkpoint differs at $path; expected $($repo.checkpoint), got $head. Preserve and inspect." }
    Write-Output "$($repo.name): $actualBranch $head"
}
$foundation = Join-Path $root 'mc-plan-foundation'
& (Join-Path $foundation 'scripts/validate-coordination.ps1') -WorkspaceRoot $root
if ($InstallSkills) {
    foreach ($name in @('mc-plan-development', 'mc-plan-orchestrator')) {
        $installer = Join-Path $foundation ".codex/skills/$name/scripts/install.ps1"
        # The canonical installer backs up an existing copy before replacing it.
        & $installer -Replace
        & $installer -Check
        if (-not $IsWindows) {
            # Current official discovery supports ~/.agents/skills. Keep the canonical
            # ~/.codex/skills installation for the project's version-drift checker.
            $agents = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.agents/skills'
            [System.IO.Directory]::CreateDirectory($agents) | Out-Null
            $alias = Join-Path $agents $name
            $codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex' }
            $target = Join-Path $codexRoot "skills/$name"
            if (Test-Path -LiteralPath $alias) {
                $entry = Get-Item -LiteralPath $alias -Force
                if ($entry.LinkType -ne 'SymbolicLink' -or [System.IO.Path]::GetFullPath($entry.ResolvedTarget) -cne [System.IO.Path]::GetFullPath($target)) {
                    throw "Existing skill alias retained at $alias; reconcile manually."
                }
            }
            else { New-Item -ItemType SymbolicLink -Path $alias -Target $target | Out-Null }
        }
    }
}
Write-Output 'Workspace restored and verified. Read docs/windows-migration.md before resuming writes.'
if ($IsWindows) { Write-Warning 'Native Windows can restore repositories, but Foundation write transactions require WSL2/Linux.' }
