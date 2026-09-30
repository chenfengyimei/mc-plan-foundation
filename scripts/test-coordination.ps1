[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$validator = Join-Path $PSScriptRoot 'validate-coordination.ps1'
$workspace = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$temporaryRoot = Join-Path $workspace '.validation/coordination-tests'
$passed = 0
$failed = 0

function Invoke-TestGit {
    param([string]$Repository, [string[]]$Arguments)
    $safe = $Repository.Replace('\', '/')
    & git -c "safe.directory=$safe" -C $Repository @Arguments | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed in $Repository" }
}

function Write-Json {
    param([string]$Path, [object]$Value)
    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding utf8NoBOM
}

function New-TestWorkspace {
    param([string]$Name)

    $root = Join-Path $temporaryRoot $Name
    $names = @('mc-plan-foundation', 'mc-plan-contracts', 'mc-plan-core', 'mc-plan-ops', 'mc-plan-skin')
    $hashes = @{}

    foreach ($repositoryName in $names) {
        $repository = Join-Path $root $repositoryName
        New-Item -ItemType Directory -Path (Join-Path $repository 'docs') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $repository 'README.md') -Value "# $repositoryName" -Encoding utf8NoBOM
        Set-Content -LiteralPath (Join-Path $repository 'AGENTS.md') -Value '# Test agent guide' -Encoding utf8NoBOM
        Set-Content -LiteralPath (Join-Path $repository 'LICENSE') -Value 'Test only' -Encoding utf8NoBOM
        Set-Content -LiteralPath (Join-Path $repository 'docs/STATUS.md') -Value '# Status' -Encoding utf8NoBOM
        Set-Content -LiteralPath (Join-Path $repository 'docs/development-plan.md') -Value '# Development plan' -Encoding utf8NoBOM
        & git -C $repository init -b main | Out-Null
        & git -C $repository config user.name 'MC Plan Test' | Out-Null
        & git -C $repository config user.email 'test@example.invalid' | Out-Null
        Invoke-TestGit $repository @('add', '-A')
        Invoke-TestGit $repository @('commit', '-m', 'test: baseline')
        $hashes[$repositoryName] = (& git -C $repository rev-parse HEAD).Trim()
    }

    $registry = [ordered]@{
        schema_version = 1
        coordination_ready = $true
        updated_at = '2026-10-01T00:00:00Z'
        repositories = @(
            [ordered]@{ name='mc-plan-foundation'; path='mc-plan-foundation'; kind='governance'; visibility='public'; lifecycle='active' },
            [ordered]@{ name='mc-plan-contracts'; path='mc-plan-contracts'; kind='contracts'; visibility='public'; lifecycle='active' },
            [ordered]@{ name='mc-plan-core'; path='mc-plan-core'; kind='service'; visibility='private'; lifecycle='active' },
            [ordered]@{ name='mc-plan-ops'; path='mc-plan-ops'; kind='operations'; visibility='private'; lifecycle='active' },
            [ordered]@{ name='mc-plan-skin'; path='mc-plan-skin'; kind='application'; visibility='public'; lifecycle='active' }
        )
    }
    $direction = [ordered]@{
        schema_version = 1
        milestone = 'F1'
        primary_repository = 'mc-plan-core'
        status = 'active'
        objective = 'Test direction'
        entry_gate = 'Test gate'
        exit_criteria = @('Test exit')
        allowed_supporting_repositories = @('mc-plan-contracts', 'mc-plan-ops')
        updated_at = '2026-10-01T00:00:00Z'
    }
    Write-Json (Join-Path $root 'mc-plan-foundation/memory/current/repositories.json') $registry
    Write-Json (Join-Path $root 'mc-plan-foundation/memory/current/direction.json') $direction
    New-Item -ItemType Directory -Path (Join-Path $root 'mc-plan-foundation/memory/workstreams/active') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $root 'mc-plan-foundation/memory/workstreams/completed') -Force | Out-Null

    return [pscustomobject]@{ Root=$root; Hashes=$hashes; Registry=$registry; Direction=$direction }
}

function New-Workstream {
    param(
        [object]$Fixture,
        [string]$TrackingId = 'MCP-F1-CORE-001',
        [string]$Primary = 'mc-plan-core',
        [string[]]$Supporting = @(),
        [string[]]$References = @('mc-plan-foundation'),
        [string]$Milestone = 'F1',
        [string]$Status = 'active',
        [switch]$Completed
    )

    $repositories = [ordered]@{}
    foreach ($name in @($Primary) + @($Supporting)) {
        $branch = "feat/$TrackingId-test"
        $repositories[$name] = [ordered]@{
            base_commit = $Fixture.Hashes[$name]
            branch = $branch
            last_checkpoint_commit = $null
            final_commit = if ($Completed) { $Fixture.Hashes[$name] } else { $null }
        }
    }
    return [ordered]@{
        schema_version = 1
        tracking_id = $TrackingId
        title = 'Coordination test'
        status = $Status
        milestone = $Milestone
        initial_owner = 'test-owner'
        owner = 'test-owner'
        started_at = '2026-10-01T00:00:00Z'
        updated_at = '2026-10-01T00:00:00Z'
        primary_repository = $Primary
        supporting_repositories = @($Supporting)
        reference_repositories = @($References)
        objective = 'Test objective'
        in_scope = @('test')
        out_of_scope = @('production')
        contract_impact = 'none'
        acceptance_evidence = if ($Completed) { @('test evidence') } else { @() }
        repositories = $repositories
        depends_on = @()
        blocked_reason = $null
        direction_exception = $null
        handoff_history = @()
        validation_results = if ($Completed) { @('test validation') } else { @() }
    }
}

function Set-WorkstreamBranches {
    param([object]$Fixture, [object]$Record)
    foreach ($property in $Record.repositories.GetEnumerator()) {
        Invoke-TestGit (Join-Path $Fixture.Root $property.Key) @('switch', '-c', [string]$property.Value.branch)
    }
}

function Add-Record {
    param([object]$Fixture, [object]$Record, [switch]$Completed)
    $bucket = if ($Completed) { 'completed' } else { 'active' }
    Write-Json (Join-Path $Fixture.Root "mc-plan-foundation/memory/workstreams/$bucket/$($Record.tracking_id).json") $Record
}

function Assert-Validation {
    param([string]$Name, [scriptblock]$Arrange, [bool]$ShouldPass, [string]$TrackingId, [string]$Phase = 'Continue')

    $fixture = New-TestWorkspace $Name
    & $Arrange $fixture
    $didPass = $true
    try {
        & $validator -WorkspaceRoot $fixture.Root -TrackingId $TrackingId -Phase $Phase -ErrorAction Stop | Out-Null
    }
    catch { $didPass = $false }

    if ($didPass -ne $ShouldPass) {
        $script:failed++
        Write-Error "Case $Name expected pass=$ShouldPass but got pass=$didPass"
    }
    else {
        $script:passed++
        Write-Output "PASS $Name"
    }
}

if (Test-Path -LiteralPath $temporaryRoot) {
    $resolved = [System.IO.Path]::GetFullPath($temporaryRoot)
    $expected = [System.IO.Path]::GetFullPath((Join-Path $workspace '.validation/coordination-tests'))
    if ($resolved -ne $expected) { throw "Refusing cleanup outside expected test path: $resolved" }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null

try {
    Assert-Validation 'single-primary' {
        param($f) $r=New-Workstream $f; Add-Record $f $r; Set-WorkstreamBranches $f $r
    } $true 'MCP-F1-CORE-001' 'Start'

    Assert-Validation 'two-supports' {
        param($f) $r=New-Workstream $f -Supporting @('mc-plan-contracts','mc-plan-ops'); Add-Record $f $r; Set-WorkstreamBranches $f $r
    } $true 'MCP-F1-CORE-001' 'Start'

    Assert-Validation 'three-supports' {
        param($f) $r=New-Workstream $f -Supporting @('mc-plan-contracts','mc-plan-ops','mc-plan-skin'); Add-Record $f $r
    } $false 'MCP-F1-CORE-001'

    Assert-Validation 'direction-mismatch' {
        param($f) $r=New-Workstream $f -Primary 'mc-plan-skin'; Add-Record $f $r
    } $false 'MCP-F1-CORE-001'

    Assert-Validation 'overlapping-locks' {
        param($f)
        $a=New-Workstream $f
        $b=New-Workstream $f -TrackingId 'MCP-F1-CONTRACTS-002' -Primary 'mc-plan-contracts' -Supporting @('mc-plan-core')
        Add-Record $f $a; Add-Record $f $b
    } $false ''

    Assert-Validation 'readonly-overlap' {
        param($f)
        $a=New-Workstream $f -References @('mc-plan-foundation','mc-plan-contracts')
        $b=New-Workstream $f -TrackingId 'MCP-F1-CONTRACTS-002' -Primary 'mc-plan-contracts' -References @('mc-plan-foundation','mc-plan-core')
        Add-Record $f $a; Add-Record $f $b
    } $true ''

    Assert-Validation 'active-repository-missing' {
        param($f)
        $f.Registry.repositories += [ordered]@{name='mc-plan-missing';path='mc-plan-missing';kind='module';visibility='private';lifecycle='active'}
        Write-Json (Join-Path $f.Root 'mc-plan-foundation/memory/current/repositories.json') $f.Registry
    } $false ''

    Assert-Validation 'proposed-repository-may-be-missing' {
        param($f)
        $f.Registry.repositories += [ordered]@{name='mc-plan-future';path='mc-plan-future';kind='module';visibility='private';lifecycle='proposed'}
        Write-Json (Join-Path $f.Root 'mc-plan-foundation/memory/current/repositories.json') $f.Registry
    } $true ''

    Assert-Validation 'unknown-workstream-repository' {
        param($f)
        $r=New-Workstream $f -Primary 'mc-plan-unknown'; Add-Record $f $r
    } $false 'MCP-F1-CORE-001'

    Assert-Validation 'branch-mismatch' {
        param($f) $r=New-Workstream $f; Add-Record $f $r
    } $false 'MCP-F1-CORE-001' 'Start'

    Assert-Validation 'undeclared-dirty-repository' {
        param($f)
        $r=New-Workstream $f; Add-Record $f $r; Set-WorkstreamBranches $f $r
        Set-Content -LiteralPath (Join-Path $f.Root 'mc-plan-skin/dirty.txt') -Value 'dirty' -Encoding utf8NoBOM
    } $false 'MCP-F1-CORE-001'

    Assert-Validation 'finish-missing-evidence' {
        param($f)
        $r=New-Workstream $f -Status 'completed' -Completed
        $r.acceptance_evidence=@(); Add-Record $f $r -Completed
    } $false 'MCP-F1-CORE-001' 'Finish'

    Assert-Validation 'takeover-without-history' {
        param($f)
        $r=New-Workstream $f; $r.owner='new-owner'; Add-Record $f $r
    } $false 'MCP-F1-CORE-001'

    Assert-Validation 'takeover-with-history' {
        param($f)
        $r=New-Workstream $f
        $r.owner='new-owner'
        $r.handoff_history=@([ordered]@{from_owner='test-owner';to_owner='new-owner';at='2026-10-01T01:00:00Z';reason='Explicit test takeover'})
        Add-Record $f $r; Set-WorkstreamBranches $f $r
    } $true 'MCP-F1-CORE-001' 'Continue'
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}

if ($failed -ne 0) { throw "Coordination tests failed: $failed failed, $passed passed." }
Write-Output "Coordination tests passed: $passed cases."
