[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$entry = Join-Path $PSScriptRoot 'invoke-foundation-write.ps1'
$pwsh = (Get-Process -Id $PID).Path
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("mc-plan write spaces " + [guid]::NewGuid().ToString('N'))
$passed = 0
$processes = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Pass {
    param([string]$Name)
    $script:passed++
    Write-Output "PASS $Name"
}
function New-WriteFixture {
    param([string]$Name)
    $root = Join-Path $temporaryRoot $Name
    $repo = Join-Path $root 'mc-plan-foundation'
    New-Item -ItemType Directory -Path (Join-Path $repo 'memory/workstreams/active') -Force | Out-Null
    & git -C $repo init -q -b main
    & git -C $repo config user.name 'MC Plan Test'
    & git -C $repo config user.email 'test@example.invalid'
    Set-Content -LiteralPath (Join-Path $repo 'README.md') -Value '# fixture'
    & git -C $repo add -- README.md
    & git -C $repo commit -q -m fixture
    return $root
}
function Start-Writer {
    param([string]$Root, [string]$Session, [string]$Script)
    $start = [System.Diagnostics.ProcessStartInfo]::new($pwsh)
    $start.UseShellExecute=$false; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    foreach ($argument in @('-NoProfile','-File',$entry,'-WorkspaceRoot',$Root,'-Session',$Session,'-TrackingId','MCP-F1-CORE-001','-Transaction','isolated test','-TransactionScript',$Script)) {
        $start.ArgumentList.Add($argument)
    }
    $process = [System.Diagnostics.Process]::Start($start)
    $script:processes.Add($process)
    return $process
}
function Finish-Writer {
    param([System.Diagnostics.Process]$Process)
    if (-not $Process.WaitForExit(15000)) { throw 'Writer test timed out' }
    return @{ ExitCode=$Process.ExitCode; Output=$Process.StandardOutput.ReadToEnd() + $Process.StandardError.ReadToEnd() }
}
function Expect-Failure {
    param([scriptblock]$Body, [string]$Diagnostic)
    $message = ''
    try { & $Body } catch { $message=$_.Exception.Message }
    Assert-True ($message.Contains($Diagnostic)) "Expected failure '$Diagnostic', got '$message'"
}

try {
    $root = New-WriteFixture 'two writers'
    $firstScript = Join-Path $temporaryRoot 'first writer.ps1'
    $secondScript = Join-Path $temporaryRoot 'second writer.ps1'
    @'
param($Context)
[System.IO.File]::WriteAllText((Join-Path $Context.WorkspaceRoot 'first-entered'), 'entered')
$deadline = [DateTime]::UtcNow.AddSeconds(10)
while (-not (Test-Path -LiteralPath (Join-Path $Context.WorkspaceRoot 'release'))) {
    if ([DateTime]::UtcNow -gt $deadline) { throw 'Test release deadline exceeded' }
    Start-Sleep -Milliseconds 20
}
'@ | Set-Content -LiteralPath $firstScript
    @'
param($Context)
[System.IO.File]::WriteAllText((Join-Path $Context.WorkspaceRoot 'second-entered'), 'entered')
'@ | Set-Content -LiteralPath $secondScript
    $first = Start-Writer $root 'first-session' $firstScript
    $deadline = [DateTime]::UtcNow.AddSeconds(10)
    while (-not (Test-Path -LiteralPath (Join-Path $root 'first-entered'))) {
        if ($first.HasExited -or [DateTime]::UtcNow -gt $deadline) { throw "First writer failed to enter: $($first.StandardError.ReadToEnd())" }
        Start-Sleep -Milliseconds 20
    }
    $holderPath = Join-Path $root '.mc-plan-foundation-write.lock/holder.json'
    $holder = Get-Content -LiteralPath $holderPath -Raw | ConvertFrom-Json
    Assert-True ($holder.session -eq 'first-session' -and $holder.tracking_id -eq 'MCP-F1-CORE-001' -and $holder.token -and $holder.acquired_at -and $holder.transaction) 'Missing holder evidence'
    Pass 'holder session/task/time/transaction/token evidence'
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $second = Finish-Writer (Start-Writer $root 'second-session' $secondScript)
    Assert-True ($second.ExitCode -ne 0 -and $second.Output.Contains('first-session') -and $second.Output.Contains('no retry')) 'Contender did not report holder immediately'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $root 'second-entered'))) 'Both writers entered'
    Assert-True ((Get-Content -LiteralPath $holderPath -Raw | ConvertFrom-Json).token -ceq $holder.token) 'Contender changed holder'
    Assert-True ($watch.Elapsed.TotalSeconds -lt 10) 'Contender waited for release'
    Pass 'two processes exclude concurrent entry and contender cannot release holder'
    Set-Content -LiteralPath (Join-Path $root 'release') -Value release
    $result = Finish-Writer $first
    Assert-True ($result.ExitCode -eq 0 -and -not (Test-Path -LiteralPath (Join-Path $root '.mc-plan-foundation-write.lock'))) "First writer failed: $($result.Output)"
    $result = Finish-Writer (Start-Writer $root 'second-session' $secondScript)
    Assert-True ($result.ExitCode -eq 0 -and (Test-Path -LiteralPath (Join-Path $root 'second-entered'))) 'Next separate attempt could not enter after release'
    Pass 'normal release permits next independent attempt with spaced paths'

    $root = New-WriteFixture 'exception release'
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction exception -Action { throw 'expected transaction failure' } } 'expected transaction failure'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $root '.mc-plan-foundation-write.lock'))) 'Exception leaked owned lock'
    Pass 'terminating exception releases only own lock'

    $root = New-WriteFixture 'native failure'
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction native -Action { & git -C /path/that/does/not/exist status 2>$null } } '128'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $root '.mc-plan-foundation-write.lock'))) 'Native error leaked owned lock'
    Pass 'native command failure aborts and releases own lock'

    $root = New-WriteFixture 'foreign token'
    Expect-Failure {
        & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction foreign -Action {
            param($c)
            $path=Join-Path $c.WorkspaceRoot '.mc-plan-foundation-write.lock/holder.json'
            $e=Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            $e.token='different-holder-token'; $e.session='different-holder'
            $e | ConvertTo-Json | Set-Content -LiteralPath $path
            throw 'expected failure after ownership changed'
        }
    } 'ownership changed'
    $holderPath=Join-Path $root '.mc-plan-foundation-write.lock/holder.json'
    Assert-True ((Get-Content -LiteralPath $holderPath -Raw | ConvertFrom-Json).token -eq 'different-holder-token') 'Removed foreign evidence'
    Pass 'exception after token mismatch retains foreign evidence'

    $root = New-WriteFixture 'incomplete evidence'
    New-Item -ItemType Directory -Path (Join-Path $root '.mc-plan-foundation-write.lock') | Out-Null
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction missing -Action { throw 'must never enter' } } 'evidence unavailable'
    Assert-True (Test-Path -LiteralPath (Join-Path $root '.mc-plan-foundation-write.lock')) 'Removed incomplete lock'
    Pass 'incomplete preexisting lock is never expired or removed'

    $root = New-WriteFixture 'unexpected lock content'
    Expect-Failure {
        & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction extra -Action {
            param($c) Set-Content -LiteralPath (Join-Path $c.WorkspaceRoot '.mc-plan-foundation-write.lock/extra') -Value extra
        }
    } 'Unexpected lock contents'
    Assert-True (Test-Path -LiteralPath (Join-Path $root '.mc-plan-foundation-write.lock/holder.json')) 'Lost holder evidence'
    Pass 'unexpected lock content retains evidence and refuses recursive removal'

    $root = New-WriteFixture 'dirty index'
    $repo=Join-Path $root 'mc-plan-foundation'
    Set-Content -LiteralPath (Join-Path $repo 'other record.json') -Value '{}'
    & git -C $repo add -- 'other record.json'
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction dirty -Action { throw 'must never enter' } } 'must be clean'
    Assert-True ((& git -C $repo diff --cached --name-only) -eq 'other record.json') 'Altered foreign index'
    Pass 'dirty shared index rejected and preserved'

    $root = New-WriteFixture 'wrong branch'
    & git -C (Join-Path $root 'mc-plan-foundation') switch -q -c feature
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction branch -Action { throw 'must never enter' } } 'require Foundation main'
    Pass 'ordinary writer rejects a business branch'

    $root = New-WriteFixture 'foundation owner gate'
    $repo=Join-Path $root 'mc-plan-foundation'
    $record=@{tracking_id='MCP-F1-FOUNDATION-001';owner='governance-owner';primary_repository='mc-plan-foundation';supporting_repositories=@();repositories=@{'mc-plan-foundation'=@{branch='fix/MCP-F1-FOUNDATION-001-test'}}}
    $record | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $repo 'memory/workstreams/active/MCP-F1-FOUNDATION-001.json')
    & git -C $repo add -- memory/workstreams/active/MCP-F1-FOUNDATION-001.json
    & git -C $repo commit -q -m record
    Expect-Failure { & $entry -WorkspaceRoot $root -Session owner -TrackingId task -Transaction active -Action { throw 'must never enter' } } 'no active Foundation business lock'
    & git -C $repo switch -q -c fix/MCP-F1-FOUNDATION-001-test
    Expect-Failure { & $entry -WorkspaceRoot $root -Session intruder -TrackingId MCP-F1-FOUNDATION-001 -Transaction active -GovernanceBranch fix/MCP-F1-FOUNDATION-001-test -Action { throw 'must never enter' } } 'matching session/record/branch'
    & $entry -WorkspaceRoot $root -Session governance-owner -TrackingId MCP-F1-FOUNDATION-001 -Transaction active -GovernanceBranch fix/MCP-F1-FOUNDATION-001-test -Action { param($c) }
    Pass 'Foundation business lock gates ordinary writers and governance owner identity'

    Set-Content -LiteralPath (Join-Path $repo 'own.md') -Value '# own'
    & $entry -WorkspaceRoot $root -Session governance-owner -TrackingId MCP-F1-FOUNDATION-001 -Transaction checkpoint -GovernanceBranch fix/MCP-F1-FOUNDATION-001-test -GovernancePaths @('own.md') -Action {
        param($c)
        & git -C $c.FoundationPath add -- own.md
        & git -C $c.FoundationPath commit -q -m checkpoint
    }
    Set-Content -LiteralPath (Join-Path $repo 'foreign.md') -Value '# foreign'
    Expect-Failure { & $entry -WorkspaceRoot $root -Session governance-owner -TrackingId MCP-F1-FOUNDATION-001 -Transaction checkpoint -GovernanceBranch fix/MCP-F1-FOUNDATION-001-test -GovernancePaths @('own.md') -Action { throw 'must never enter' } } 'must be clean'
    Pass 'governance checkpoints accept exact own paths and reject foreign paths'

    $root = New-WriteFixture 'record commit paths'
    $repo=Join-Path $root 'mc-plan-foundation'
    & $entry -WorkspaceRoot $root -Session owner -TrackingId registration-task -Transaction register -Action {
        param($c)
        $id='MCP-F1-CORE-001'
        @{tracking_id=$id;owner=$c.Session;primary_repository='mc-plan-core';supporting_repositories=@()} | ConvertTo-Json |
            Set-Content -LiteralPath (Join-Path $c.FoundationPath "memory/workstreams/active/$id.json")
        Submit-FoundationRecord -Context $c -TrackingId $id -Message 'test: own record only'
    }
    Assert-True ((& git -C $repo show --pretty=format: --name-only HEAD).Trim() -eq 'memory/workstreams/active/MCP-F1-CORE-001.json') 'Commit included another path'
    Pass 'registration ID allocated inside action and precise own record commit'
    $before=(& git -C $repo rev-parse HEAD).Trim()
    Expect-Failure {
        & $entry -WorkspaceRoot $root -Session owner -TrackingId MCP-F1-CORE-001 -Transaction foreign-stage -Action {
            param($c)
            Set-Content -LiteralPath (Join-Path $c.FoundationPath 'portfolio.md') -Value foreign
            & git -C $c.FoundationPath add -- portfolio.md
            Submit-FoundationRecord -Context $c -Message 'must fail'
        }
    } 'only this Tracking ID'
    Assert-True ((& git -C $repo rev-parse HEAD).Trim() -eq $before -and (& git -C $repo diff --cached --name-only) -eq 'portfolio.md') 'Foreign staged state was committed or altered'
    Pass 'record helper rejects foreign staging and preserves it'
}
finally {
    foreach ($process in $processes) {
        if (-not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
    # Only this unique, test-owned temporary tree; no real workspace lock is touched.
    if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}
Write-Output "Foundation write tests passed: $passed cases."
