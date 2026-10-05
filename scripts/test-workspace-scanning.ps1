[CmdletBinding()]
param(
    [string]$ValidatorPath = (Join-Path $PSScriptRoot 'validate-workspace.ps1'),
    [switch]$ReproduceBaseline
)

$ErrorActionPreference = 'Stop'
$foundation = Split-Path -Parent $PSScriptRoot
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("mc-plan scan spaces " + [guid]::NewGuid().ToString('N'))
$pwsh = (Get-Process -Id $PID).Path
$passed = 0

function Write-FixtureFile {
    param([string]$Root, [string]$Path, [string]$Content)
    $target = Join-Path $Root $Path
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    [System.IO.File]::WriteAllText($target, $Content)
}

function Invoke-FixtureGit {
    param([string]$Repository, [string[]]$Arguments)
    & git -C $Repository @Arguments | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Fixture git failed: $($Arguments -join ' ')" }
}

function New-ScanFixture {
    param([string]$Name)
    $root = Join-Path $temporaryRoot $Name
    foreach ($name in @('mc-plan-foundation', 'mc-plan-contracts')) {
        foreach ($path in @('README.md', 'AGENTS.md', 'LICENSE', 'docs/STATUS.md', 'docs/development-plan.md')) {
            Write-FixtureFile $root "$name/$path" '# Fixture'
        }
        $repository = Join-Path $root $name
        Invoke-FixtureGit $repository @('init', '-q', '-b', 'main')
        Invoke-FixtureGit $repository @('config', 'user.name', 'MC Plan Test')
        Invoke-FixtureGit $repository @('config', 'user.email', 'test@example.invalid')
    }
    $fixtureFoundation = Join-Path $root 'mc-plan-foundation'
    New-Item -ItemType Directory -Path (Join-Path $fixtureFoundation '.codex/skills') -Force | Out-Null
    foreach ($name in @('mc-plan-development', 'mc-plan-orchestrator')) {
        Copy-Item -LiteralPath (Join-Path $foundation ".codex/skills/$name") -Destination (Join-Path $fixtureFoundation '.codex/skills') -Recurse
    }
    New-Item -ItemType Directory -Path (Join-Path $fixtureFoundation 'scripts') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'validate-coordination.ps1') -Destination (Join-Path $fixtureFoundation 'scripts')
    $registry = @{
        schema_version = 1; coordination_ready = $true
        repositories = @(
            @{ name='mc-plan-foundation'; path='mc-plan-foundation'; lifecycle='active' },
            @{ name='mc-plan-contracts'; path='mc-plan-contracts'; lifecycle='active' }
        )
    }
    Write-FixtureFile $root 'mc-plan-foundation/memory/current/repositories.json' ($registry | ConvertTo-Json -Depth 20)
    Write-FixtureFile $root 'mc-plan-foundation/memory/current/direction.json' (@{
        schema_version=1; milestone='F1'; primary_repository='mc-plan-contracts'; allowed_supporting_repositories=@()
    } | ConvertTo-Json)
    Write-FixtureFile $root 'mc-plan-contracts/schemas/valid source.json' '{"$id":"https://example.invalid/source","type":"object"}'
    Write-FixtureFile $root 'mc-plan-contracts/openapi/valid.yaml' '$ref: ../schemas/valid.json'
    Write-FixtureFile $root 'mc-plan-contracts/schemas/valid.json' '{"type":"string"}'
    Write-FixtureFile $root 'mc-plan-contracts/docs/source guide.md' '[valid](../schemas/valid%20source.json)'
    foreach ($name in @('mc-plan-foundation', 'mc-plan-contracts')) {
        $repository = Join-Path $root $name
        Invoke-FixtureGit $repository @('add', '--', '.')
        Invoke-FixtureGit $repository @('commit', '-q', '-m', 'fixture baseline')
        $base = (& git -C $repository rev-parse HEAD).Trim()
        $id = if ($name -eq 'mc-plan-foundation') { 'MCP-F1-FOUNDATION-001' } else { 'MCP-F1-CONTRACTS-001' }
        $record = Get-Content -LiteralPath (Join-Path $foundation 'templates/workstream.json') -Raw | ConvertFrom-Json -AsHashtable
        $record.tracking_id=$id; $record.primary_repository=$name; $record.reference_repositories=@(); $record.status='active'
        $record.initial_owner='fixture'; $record.owner='fixture'
        $record.repositories=@{ $name=@{base_commit=$base; branch="feat/$id-fixture"; last_checkpoint_commit=$null; final_commit=$null} }
        if ($name -eq 'mc-plan-foundation') {
            $record.direction_exception=@{category='foundation-governance'; authorized_by='fixture'; reason='fixture'}
        }
        Write-FixtureFile $root "mc-plan-foundation/memory/workstreams/active/$id.json" ($record | ConvertTo-Json -Depth 100)
    }
    return $root
}

function Assert-Scan {
    param([string]$Name, [scriptblock]$Arrange, [bool]$ShouldPass, [string]$Diagnostic = '')
    $root = New-ScanFixture $Name
    & $Arrange $root
    $output = @(& $pwsh -NoProfile -File $ValidatorPath -WorkspaceRoot $root 2>&1)
    $exitCode = $LASTEXITCODE
    if (($exitCode -eq 0) -ne $ShouldPass -or ($Diagnostic -and ($output -join "`n") -notmatch [regex]::Escape($Diagnostic))) {
        throw "Case $Name expected pass=$ShouldPass / '$Diagnostic', exit=$exitCode : $($output -join "`n")"
    }
    $script:passed++
    Write-Output "PASS $Name (exit $exitCode)"
}

try {
    Assert-Scan 'clean source with spaces' { param($r) } $true
    Assert-Scan 'dependency duplicate ids' {
        param($r)
        foreach ($name in @('one.json', 'two.json')) {
            Write-FixtureFile $r "mc-plan-contracts/node_modules/example-test/$name" '{"$id":"https://example.invalid/dependency"}'
        }
    } (-not $ReproduceBaseline) $(if ($ReproduceBaseline) { 'Duplicate JSON Schema id' } else { '' })
    Assert-Scan 'dependency relative yaml ref' {
        param($r) Write-FixtureFile $r 'mc-plan-contracts/node_modules/example-test/spec.yaml' '$ref: ./missing.yaml'
    } (-not $ReproduceBaseline) $(if ($ReproduceBaseline) { 'Missing local contract reference' } else { '' })
    if (-not $ReproduceBaseline) {
        Assert-Scan 'dependency invalid json and markdown' {
            param($r)
            foreach ($name in @('mc-plan-foundation', 'mc-plan-contracts')) {
                Write-FixtureFile $r "$name/node_modules/example-test/bad.json" '{bad'
                Write-FixtureFile $r "$name/node_modules/example-test/bad.md" '[bad](missing.md)'
            }
        } $true
        Assert-Scan 'validation products even tracked' {
            param($r)
            Write-FixtureFile $r 'mc-plan-contracts/.validation/output/bad.json' '{bad'
            Write-FixtureFile $r 'mc-plan-contracts/.validation/output/bad.yaml' '$ref: ./missing.yaml'
            Write-FixtureFile $r 'mc-plan-contracts/.validation/output/bad.md' '[bad](missing.md)'
            Invoke-FixtureGit (Join-Path $r 'mc-plan-contracts') @('add','-f','--','.validation')
        } $true
        Assert-Scan 'git internal products' {
            param($r)
            Write-FixtureFile $r 'mc-plan-contracts/.git/test-cache/bad.json' '{bad'
            Write-FixtureFile $r 'mc-plan-contracts/.git/test-cache/bad.md' '[bad](missing.md)'
        } $true
        Assert-Scan 'ignored install and build products' {
            param($r)
            Write-FixtureFile $r 'mc-plan-contracts/.gitignore' "installed/`nbuild output/`n"
            Write-FixtureFile $r 'mc-plan-contracts/installed/bad.json' '{bad'
            Write-FixtureFile $r 'mc-plan-contracts/build output/bad.yaml' '$ref: ./missing.yaml'
            Write-FixtureFile $r 'mc-plan-contracts/build output/bad.md' '[bad](missing.md)'
        } $true
        Assert-Scan 'unignored known caches' {
            param($r)
            foreach ($cache in @('dist','coverage','.next','.turbo','.pnpm-store','.cache','__pycache__','.pytest_cache','.venv')) {
                Write-FixtureFile $r "mc-plan-contracts/$cache/bad.json" '{bad'
                Write-FixtureFile $r "mc-plan-contracts/$cache/bad.yaml" '$ref: ./missing.yaml'
                Write-FixtureFile $r "mc-plan-contracts/$cache/bad.md" '[bad](missing.md)'
            }
        } $true
        Assert-Scan 'untracked valid hidden source' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/.hidden/source.json' '{"type":"object"}'
        } $true
        Assert-Scan 'untracked invalid hidden source' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/.hidden/source.json' '{bad'
        } $false 'Invalid JSON'
        Assert-Scan 'real invalid json' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/schemas/new source.json' '{bad'
        } $false 'Invalid JSON'
        Assert-Scan 'real duplicate ids' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/schemas/new source.json' '{"$id":"https://example.invalid/source"}'
        } $false 'Duplicate JSON Schema id'
        Assert-Scan 'real missing local ref' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/openapi/new source.yaml' '$ref: ../schemas/missing.json'
        } $false 'Missing local contract reference'
        Assert-Scan 'real broken markdown' {
            param($r) Write-FixtureFile $r 'mc-plan-contracts/docs/new source.md' '[bad](missing.md)'
        } $false 'Broken local link'
        Assert-Scan 'tracked ignored codex guide' {
            param($r)
            Write-FixtureFile $r 'mc-plan-foundation/.gitignore' '.codex/'
            Write-FixtureFile $r 'mc-plan-foundation/.codex/skills/mc-plan-development/SKILL.md' "---`nname: mc-plan-development`ndescription: Fixture`n---`n[bad](missing.md)"
        } $false 'Broken local link'
        Assert-Scan 'tracked source under cache named directory' {
            param($r)
            Write-FixtureFile $r 'mc-plan-contracts/dist/schema.json' '{bad'
            Invoke-FixtureGit (Join-Path $r 'mc-plan-contracts') @('add','-f','--','dist/schema.json')
        } $false 'Invalid JSON'
        Assert-Scan 'foundation coordination json' {
            param($r) Write-FixtureFile $r 'mc-plan-foundation/memory/workstreams/active/MCP-F1-FOUNDATION-001.json' '{bad'
        } $false 'Invalid JSON'
        Assert-Scan 'workspace outer products' {
            param($r) Write-FixtureFile $r 'unregistered cache/bad.md' '[bad](missing.md)'
        } $true
        Assert-Scan 'workspace must not be git' {
            param($r) New-Item -ItemType Directory -Path (Join-Path $r '.git') | Out-Null
        } $false 'Workspace root must not be a Git repository'
        Assert-Scan 'unregistered project' {
            param($r) New-Item -ItemType Directory -Path (Join-Path $r 'mc-plan-unknown') | Out-Null
        } $false 'Unregistered MC Plan directory'
        Assert-Scan 'missing registered git' {
            param($r) Remove-Item -LiteralPath (Join-Path $r 'mc-plan-contracts/.git') -Recurse -Force
        } $false '.git'
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}
Write-Output "Workspace scanning tests passed: $passed cases (baseline reproduction=$ReproduceBaseline)."
