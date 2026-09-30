[CmdletBinding()]
param(
    [string]$WorkspaceRoot,
    [string]$TrackingId,
    [ValidateSet('Start', 'Continue', 'Finish')]
    [string]$Phase = 'Continue'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$root = [System.IO.Path]::GetFullPath($WorkspaceRoot)
$foundation = Join-Path $root 'mc-plan-foundation'
$errors = [System.Collections.Generic.List[string]]::new()

function Read-JsonFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        $script:errors.Add("Missing JSON file: $Path")
        return $null
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100
    }
    catch {
        $script:errors.Add("Invalid JSON at ${Path}: $($_.Exception.Message)")
        return $null
    }
}

function Has-Property {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name]
}

function Invoke-RepoGit {
    param([string]$RepositoryPath, [string[]]$Arguments, [switch]$AllowFailure)

    $safePath = $RepositoryPath.Replace('\', '/')
    $output = @(& git -c "safe.directory=$safePath" -C $RepositoryPath @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "git $($Arguments -join ' ') failed in ${RepositoryPath}: $($output -join ' ')"
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = $output }
}

function Get-Array {
    param([object]$Value)
    if ($null -eq $Value) { return @() }
    return @($Value)
}

$registryPath = Join-Path $foundation 'memory/current/repositories.json'
$directionPath = Join-Path $foundation 'memory/current/direction.json'
$registry = Read-JsonFile $registryPath
$direction = Read-JsonFile $directionPath
$repositoryByName = @{}

if ($null -ne $registry) {
    if ($registry.schema_version -ne 1) { $errors.Add('Repository registry schema_version must be 1.') }
    if (-not (Has-Property $registry 'coordination_ready')) { $errors.Add('Repository registry is missing coordination_ready.') }
    foreach ($repository in (Get-Array $registry.repositories)) {
        if ([string]::IsNullOrWhiteSpace([string]$repository.name)) {
            $errors.Add('Repository registry contains an entry without name.')
            continue
        }
        if ($repositoryByName.ContainsKey([string]$repository.name)) {
            $errors.Add("Duplicate repository name: $($repository.name)")
            continue
        }
        if ([string]$repository.lifecycle -notin @('proposed', 'approved', 'active', 'retired')) {
            $errors.Add("Invalid lifecycle for $($repository.name): $($repository.lifecycle)")
        }
        $repositoryByName[[string]$repository.name] = $repository

        if ($repository.lifecycle -eq 'active') {
            $repositoryPath = Join-Path $root ([string]$repository.path)
            if (-not (Test-Path -LiteralPath $repositoryPath -PathType Container)) {
                $errors.Add("Active repository directory is missing: $($repository.name)")
                continue
            }
            foreach ($required in @('.git', 'README.md', 'AGENTS.md', 'LICENSE', 'docs/STATUS.md')) {
                if (-not (Test-Path -LiteralPath (Join-Path $repositoryPath $required))) {
                    $errors.Add("Active repository $($repository.name) is missing $required")
                }
            }
            if ($registry.coordination_ready -eq $true -and -not (Test-Path -LiteralPath (Join-Path $repositoryPath 'docs/development-plan.md'))) {
                $errors.Add("Coordination-ready repository $($repository.name) is missing docs/development-plan.md")
            }
        }
    }
}

if ($null -ne $direction) {
    if ($direction.schema_version -ne 1) { $errors.Add('Current direction schema_version must be 1.') }
    if (-not $repositoryByName.ContainsKey([string]$direction.primary_repository)) {
        $errors.Add("Current direction references unknown primary repository: $($direction.primary_repository)")
    }
    foreach ($name in (Get-Array $direction.allowed_supporting_repositories)) {
        if (-not $repositoryByName.ContainsKey([string]$name)) {
            $errors.Add("Current direction references unknown supporting repository: $name")
        }
    }
}

$activeDirectory = Join-Path $foundation 'memory/workstreams/active'
$completedDirectory = Join-Path $foundation 'memory/workstreams/completed'
$activeRecords = @()
$completedRecords = @()

foreach ($definition in @(
    @{ Directory = $activeDirectory; Expected = 'active' },
    @{ Directory = $completedDirectory; Expected = 'completed' }
)) {
    if (-not (Test-Path -LiteralPath $definition.Directory)) { continue }
    foreach ($file in (Get-ChildItem -LiteralPath $definition.Directory -File -Filter '*.json')) {
        $record = Read-JsonFile $file.FullName
        if ($null -eq $record) { continue }
        $record | Add-Member -NotePropertyName '_file' -NotePropertyValue $file.FullName
        $record | Add-Member -NotePropertyName '_bucket' -NotePropertyValue $definition.Expected
        if ($definition.Expected -eq 'active') { $activeRecords += $record } else { $completedRecords += $record }
    }
}

$requiredFields = @(
    'schema_version', 'tracking_id', 'title', 'status', 'milestone', 'initial_owner', 'owner',
    'started_at', 'updated_at', 'primary_repository', 'supporting_repositories',
    'reference_repositories', 'objective', 'in_scope', 'out_of_scope',
    'contract_impact', 'acceptance_evidence', 'repositories', 'depends_on',
    'blocked_reason', 'direction_exception', 'handoff_history', 'validation_results'
)
$allowedExceptionCategories = @('security', 'data-loss', 'compliance', 'foundation-governance')

foreach ($record in @($activeRecords) + @($completedRecords)) {
    foreach ($field in $requiredFields) {
        if (-not (Has-Property $record $field)) { $errors.Add("$($record._file) is missing field $field") }
    }
    if ($record.schema_version -ne 1) { $errors.Add("$($record._file) schema_version must be 1.") }
    if ([string]$record.tracking_id -notmatch '^MCP-[A-Z0-9]+-[A-Z0-9]+-[0-9]{3}$') {
        $errors.Add("Invalid tracking_id in $($record._file): $($record.tracking_id)")
    }
    if ([System.IO.Path]::GetFileNameWithoutExtension([string]$record._file) -ne [string]$record.tracking_id) {
        $errors.Add("Workstream filename does not match tracking_id: $($record._file)")
    }

    $supporting = @(Get-Array $record.supporting_repositories)
    $references = @(Get-Array $record.reference_repositories)
    if ($supporting.Count -gt 2) { $errors.Add("$($record.tracking_id) has more than two supporting repositories.") }
    if (@($supporting | Sort-Object -Unique).Count -ne $supporting.Count) { $errors.Add("$($record.tracking_id) repeats a supporting repository.") }
    if (@($references | Sort-Object -Unique).Count -ne $references.Count) { $errors.Add("$($record.tracking_id) repeats a reference repository.") }

    $locked = @([string]$record.primary_repository) + $supporting
    if ([string]::IsNullOrWhiteSpace([string]$record.primary_repository)) { $errors.Add("$($record.tracking_id) has no primary repository.") }
    if (@($locked | Sort-Object -Unique).Count -ne $locked.Count) { $errors.Add("$($record.tracking_id) repeats a locked repository.") }
    foreach ($name in $locked + $references) {
        if (-not $repositoryByName.ContainsKey([string]$name)) {
            $errors.Add("$($record.tracking_id) references unknown repository: $name")
        }
        elseif ($repositoryByName[[string]$name].lifecycle -ne 'active') {
            $errors.Add("$($record.tracking_id) references non-active repository: $name")
        }
    }
    foreach ($name in $locked) {
        if (-not (Has-Property $record.repositories ([string]$name))) {
            $errors.Add("$($record.tracking_id) has no repository state for locked repository $name")
        }
    }
    foreach ($property in @($record.repositories.PSObject.Properties)) {
        if ($locked -notcontains $property.Name) {
            $errors.Add("$($record.tracking_id) stores write state for undeclared repository $($property.Name)")
        }
        $state = $property.Value
        if ([string]$state.base_commit -notmatch '^[0-9a-f]{40}$') { $errors.Add("$($record.tracking_id) has invalid base_commit for $($property.Name)") }
        if ([string]$state.branch -notmatch [regex]::Escape([string]$record.tracking_id)) { $errors.Add("$($record.tracking_id) branch for $($property.Name) must contain the tracking ID.") }
    }

    if ([string]$record.owner -ne [string]$record.initial_owner) {
        $history = @(Get-Array $record.handoff_history)
        if ($history.Count -eq 0) {
            $errors.Add("$($record.tracking_id) changed Owner without handoff or takeover history.")
        }
        else {
            $latest = $history[-1]
            if ([string]$latest.to_owner -ne [string]$record.owner -or
                [string]::IsNullOrWhiteSpace([string]$latest.from_owner) -or
                [string]::IsNullOrWhiteSpace([string]$latest.reason) -or
                [string]::IsNullOrWhiteSpace([string]$latest.at)) {
                $errors.Add("$($record.tracking_id) latest handoff does not justify its current Owner.")
            }
        }
    }

    if ($record._bucket -eq 'active') {
        if ([string]$record.status -notin @('planned', 'active', 'blocked', 'handoff_required')) {
            $errors.Add("Active workstream $($record.tracking_id) has invalid status $($record.status)")
        }
        $allowedDirectionRepositories = @([string]$direction.primary_repository) + @(Get-Array $direction.allowed_supporting_repositories)
        $aligned = [string]$record.milestone -eq [string]$direction.milestone -and $allowedDirectionRepositories -contains [string]$record.primary_repository
        if (-not $aligned) {
            if ($null -eq $record.direction_exception) {
                $errors.Add("$($record.tracking_id) is outside the current direction without an exception.")
            }
            elseif ([string]$record.direction_exception.category -notin $allowedExceptionCategories -or
                    [string]::IsNullOrWhiteSpace([string]$record.direction_exception.authorized_by) -or
                    [string]::IsNullOrWhiteSpace([string]$record.direction_exception.reason)) {
                $errors.Add("$($record.tracking_id) has an invalid direction exception.")
            }
        }
    }
    elseif ([string]$record.status -notin @('completed', 'cancelled')) {
        $errors.Add("Completed workstream $($record.tracking_id) has invalid status $($record.status)")
    }
}

$locks = @{}
foreach ($record in $activeRecords) {
    foreach ($name in @([string]$record.primary_repository) + @(Get-Array $record.supporting_repositories)) {
        if ($locks.ContainsKey($name)) {
            $errors.Add("Repository lock overlap: $name is used by $($locks[$name]) and $($record.tracking_id)")
        }
        else { $locks[$name] = [string]$record.tracking_id }
    }
}

$selected = $null
if (-not [string]::IsNullOrWhiteSpace($TrackingId)) {
    $source = if ($Phase -eq 'Finish') { $completedRecords } else { $activeRecords }
    $selected = @($source | Where-Object { $_.tracking_id -eq $TrackingId })
    if ($selected.Count -ne 1) {
        $errors.Add("Expected exactly one $Phase record for $TrackingId, found $($selected.Count).")
        $selected = $null
    }
    else { $selected = $selected[0] }
}

if ($null -ne $selected) {
    foreach ($property in @($selected.repositories.PSObject.Properties)) {
        $name = $property.Name
        $state = $property.Value
        if (-not $repositoryByName.ContainsKey($name)) { continue }
        $repositoryPath = Join-Path $root ([string]$repositoryByName[$name].path)
        $baseCheck = Invoke-RepoGit $repositoryPath @('cat-file', '-e', "$($state.base_commit)^{commit}") -AllowFailure
        if ($baseCheck.ExitCode -ne 0) { $errors.Add("$TrackingId base commit is missing in ${name}: $($state.base_commit)") }

        if ($Phase -in @('Start', 'Continue')) {
            $branch = (Invoke-RepoGit $repositoryPath @('branch', '--show-current')).Output -join ''
            if ($branch -ne [string]$state.branch) { $errors.Add("$TrackingId expects branch $($state.branch) in $name, found $branch") }
            $ancestor = Invoke-RepoGit $repositoryPath @('merge-base', '--is-ancestor', [string]$state.base_commit, 'HEAD') -AllowFailure
            if ($ancestor.ExitCode -ne 0) { $errors.Add("$TrackingId base commit is not an ancestor of HEAD in $name") }
        }
        else {
            if (@(Get-Array $selected.acceptance_evidence).Count -eq 0) { $errors.Add("$TrackingId has no acceptance evidence.") }
            if (@(Get-Array $selected.validation_results).Count -eq 0) { $errors.Add("$TrackingId has no validation results.") }
            if ([string]$state.final_commit -notmatch '^[0-9a-f]{40}$') {
                $errors.Add("$TrackingId has invalid final_commit for $name")
            }
            else {
                $finalCheck = Invoke-RepoGit $repositoryPath @('cat-file', '-e', "$($state.final_commit)^{commit}") -AllowFailure
                if ($finalCheck.ExitCode -ne 0) { $errors.Add("$TrackingId final commit is missing in ${name}: $($state.final_commit)") }
                $ancestor = Invoke-RepoGit $repositoryPath @('merge-base', '--is-ancestor', [string]$state.base_commit, [string]$state.final_commit) -AllowFailure
                if ($ancestor.ExitCode -ne 0) { $errors.Add("$TrackingId final commit does not descend from its base in $name") }
            }
            $status = @((Invoke-RepoGit $repositoryPath @('status', '--porcelain=v1', '--untracked-files=all')).Output)
            if ($status.Count -ne 0) { $errors.Add("$TrackingId cannot finish because $name is dirty.") }
        }
    }
}

foreach ($repository in $repositoryByName.Values | Where-Object { $_.lifecycle -eq 'active' }) {
    $repositoryPath = Join-Path $root ([string]$repository.path)
    if (-not (Test-Path -LiteralPath (Join-Path $repositoryPath '.git'))) { continue }
    $status = @((Invoke-RepoGit $repositoryPath @('status', '--porcelain=v1', '--untracked-files=all')).Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($status.Count -eq 0) { continue }
    if ($locks.ContainsKey([string]$repository.name)) { continue }

    $coordinationOnly = $repository.name -eq 'mc-plan-foundation'
    foreach ($line in $status) {
        $path = if ($line.Length -gt 3) { $line.Substring(3).Trim('"') } else { '' }
        if ($path -notmatch '^memory/workstreams/(active|completed)/[^/]+\.json$' -and
            $path -notin @('memory/current/direction.json', 'memory/current/repositories.json')) {
            $coordinationOnly = $false
        }
    }
    if (-not $coordinationOnly) {
        $errors.Add("Dirty repository is not covered by an active lock: $($repository.name)")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Coordination validation failed with $($errors.Count) error(s)."
}

$activeCount = $activeRecords.Count
$completedCount = $completedRecords.Count
$message = "Coordination validation passed: $($repositoryByName.Count) registered repositories, $activeCount active and $completedCount completed workstreams."
if (-not [string]::IsNullOrWhiteSpace($TrackingId)) { $message += " $TrackingId passed phase $Phase." }
Write-Output $message
