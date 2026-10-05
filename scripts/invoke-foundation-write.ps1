[CmdletBinding(DefaultParameterSetName = 'Script')]
param(
    [Parameter(Mandatory)][string]$WorkspaceRoot,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Session,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$TrackingId,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Transaction,
    [Parameter(Mandatory, ParameterSetName = 'Script')][string]$TransactionScript,
    [Parameter(Mandatory, ParameterSetName = 'Action')][scriptblock]$Action,
    [string]$GovernanceBranch,
    [string[]]$GovernancePaths = @()
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$root = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$foundation = Join-Path $root 'mc-plan-foundation'
$lock = Join-Path $root '.mc-plan-foundation-write.lock'
$holderPath = Join-Path $lock 'holder.json'
$token = [guid]::NewGuid().ToString('N')

function Submit-FoundationRecord {
    param([Parameter(Mandatory)]$Context, [Parameter(Mandatory)][string]$Message, [string]$TrackingId = $Context.TrackingId)
    if ($TrackingId -notmatch '^MCP-[A-Z0-9]+-[A-Z0-9]+-[0-9]{3}$') { throw 'Record commit requires the allocated Tracking ID.' }
    $allowed = @("memory/workstreams/active/$TrackingId.json", "memory/workstreams/completed/$TrackingId.json")
    $pending = @(
        & git -c core.quotepath=false -C $Context.FoundationPath diff --name-only
        & git -c core.quotepath=false -C $Context.FoundationPath diff --cached --name-only
        & git -c core.quotepath=false -C $Context.FoundationPath ls-files --others --exclude-standard
    ) | Sort-Object -Unique
    $pending = @($pending)
    if (@($pending).Count -eq 0 -or @($pending | Where-Object { $allowed -cnotcontains $_ }).Count -gt 0) {
        throw 'Record commit rejected: only this Tracking ID active/completed paths may be staged; preserve all changes/index.'
    }
    foreach ($path in $allowed) {
        $full = Join-Path $Context.FoundationPath $path
        if (Test-Path -LiteralPath $full -PathType Leaf) {
            $record = Get-Content -LiteralPath $full -Raw | ConvertFrom-Json -Depth 100
            if ($record.tracking_id -cne $TrackingId -or $record.owner -cne $Context.Session) {
                throw 'Record identity/owner must match the allocated ID and transaction session.'
            }
        }
    }
    & git -C $Context.FoundationPath add -- @pending
    $staged = @(& git -c core.quotepath=false -C $Context.FoundationPath diff --cached --name-only)
    if (@($staged | Where-Object { $allowed -cnotcontains $_ }).Count -gt 0) { throw 'Foreign staged paths; refusing commit.' }
    & git -C $Context.FoundationPath commit -m $Message
}

if ($IsWindows) { throw 'This same-Mac/Unix entry requires atomic /bin/mkdir; Windows is not supported.' }
if ($PSCmdlet.ParameterSetName -eq 'Script') {
    $TransactionScript = (Resolve-Path -LiteralPath $TransactionScript).Path
}

# Directory.CreateDirectory is not exclusive. Native mkdir atomically fails if occupied.
$start = [System.Diagnostics.ProcessStartInfo]::new('/bin/mkdir')
$start.UseShellExecute = $false
$start.RedirectStandardError = $true
foreach ($argument in @('-m', '700', '--', $lock)) { $start.ArgumentList.Add($argument) }
$mkdir = [System.Diagnostics.Process]::Start($start)
try {
    $mkdirError = $mkdir.StandardError.ReadToEnd()
    $mkdir.WaitForExit()
    if ($mkdir.ExitCode -ne 0) {
        $holder = if (Test-Path -LiteralPath $holderPath -PathType Leaf) {
            [System.IO.File]::ReadAllText($holderPath)
        } else { 'Holder evidence unavailable (acquisition may be in progress); retain the lock.' }
        throw "Foundation write lock unavailable; no retry. Holder: $holder mkdir: $mkdirError"
    }
}
finally { $mkdir.Dispose() }

$evidenceWritten = $false
try {
    $evidence = [ordered]@{
        schema_version = 1
        token = $token
        session = $Session
        tracking_id = $TrackingId
        acquired_at = [DateTimeOffset]::UtcNow.ToString('o')
        transaction = $Transaction
        pid = $PID
    }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($evidence | ConvertTo-Json) + "`n")
    $file = [System.IO.File]::Open($holderPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    try { $file.Write($bytes, 0, $bytes.Length); $file.Flush($true) }
    finally { $file.Dispose() }
    $evidenceWritten = $true

    $branch = (& git -C $foundation branch --show-current).Trim()
    $status = @(& git -C $foundation status --porcelain=v1 --untracked-files=all)
    if ($GovernancePaths.Count -gt 0 -and -not $GovernanceBranch) { throw 'GovernancePaths requires GovernanceBranch.' }
    if ($status.Count -ne 0) {
        $changedPaths = @(
            & git -c core.quotepath=false -C $foundation diff --name-only
            & git -c core.quotepath=false -C $foundation diff --cached --name-only
            & git -c core.quotepath=false -C $foundation ls-files --others --exclude-standard
        )
        $foreign = @($changedPaths | Where-Object { $GovernancePaths -cnotcontains $_ })
        if (-not $GovernanceBranch -or $foreign.Count -gt 0) {
            throw "Foundation must be clean before a transaction (governance may declare exact own paths); preserve files/index: $($status -join '; ')"
        }
    }
    $records = @(Get-ChildItem -LiteralPath (Join-Path $foundation 'memory/workstreams/active') -Filter '*.json' -File |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -Depth 100 })
    $foundationOwners = @($records | Where-Object {
        $_.primary_repository -eq 'mc-plan-foundation' -or @($_.supporting_repositories) -contains 'mc-plan-foundation'
    })
    if ($GovernanceBranch) {
        $ownRecord = @($foundationOwners | Where-Object {
            $_.tracking_id -eq $TrackingId -and $_.owner -eq $Session -and
            $_.repositories.'mc-plan-foundation'.branch -eq $GovernanceBranch
        })
        if ($branch -ne $GovernanceBranch -or $ownRecord.Count -ne 1 -or $foundationOwners.Count -ne 1) {
            throw 'Governance branch mode requires the single active Foundation owner, matching session/record/branch.'
        }
    }
    elseif ($branch -ne 'main' -or $foundationOwners.Count -ne 0) {
        throw 'Ordinary coordination transactions require Foundation main and no active Foundation business lock.'
    }
    $context = [pscustomobject]@{
        WorkspaceRoot = $root
        FoundationPath = $foundation
        TrackingId = $TrackingId
        Session = $Session
        ActiveRecordPath = "memory/workstreams/active/$TrackingId.json"
        CompletedRecordPath = "memory/workstreams/completed/$TrackingId.json"
    }
    if ($PSCmdlet.ParameterSetName -eq 'Script') {
        $global:LASTEXITCODE = 0
        & $TransactionScript -Context $context
        if ($LASTEXITCODE -ne 0) { throw "Transaction script exited with code $LASTEXITCODE" }
    }
    else { & $Action $context }
    $remaining = @(& git -C $foundation status --porcelain=v1 --untracked-files=all)
    if ($remaining.Count -ne 0) { throw "Transaction left uncommitted Foundation changes; preserve them and return to coordination: $($remaining -join '; ')" }
    if (-not $GovernanceBranch -and (& git -C $foundation branch --show-current).Trim() -ne 'main') {
        throw 'Ordinary transaction changed the Foundation branch; preserve state and return to coordination.'
    }
}
finally {
    # A failed mkdir never reaches here. PID/time are evidence, never release authority.
    if ($evidenceWritten -and (Test-Path -LiteralPath $holderPath -PathType Leaf)) {
        $holder = Get-Content -LiteralPath $holderPath -Raw | ConvertFrom-Json
        if ($holder.token -ceq $token) {
            $unexpected = @(Get-ChildItem -LiteralPath $lock -Force | Where-Object { $_.Name -cne 'holder.json' })
            if ($unexpected.Count -gt 0) { throw "Unexpected lock contents; retained holder evidence at $holderPath." }
            Remove-Item -LiteralPath $holderPath
            # Non-recursive removal refuses unexpected content rather than deleting it.
            [System.IO.Directory]::Delete($lock, $false)
        }
        else { throw "Foundation lock ownership changed; retained evidence at $holderPath. No automatic takeover." }
    }
    else { throw "Foundation lock evidence missing/incomplete; retain $lock for owner reconciliation." }
}
