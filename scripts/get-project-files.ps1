# Shared read-only inventory: Git tracked files plus non-ignored untracked files.
function Get-ProjectFiles {
    param([Parameter(Mandatory)][string]$RepositoryPath)

    $repository = [System.IO.Path]::GetFullPath($RepositoryPath)
    function Read-GitPaths {
        param([string[]]$Arguments)
        $start = [System.Diagnostics.ProcessStartInfo]::new('git')
        $start.UseShellExecute = $false
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        foreach ($argument in @('-C', $repository) + $Arguments) { $start.ArgumentList.Add($argument) }
        $process = [System.Diagnostics.Process]::Start($start)
        try {
            $output = $process.StandardOutput.ReadToEnd()
            $errorText = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            if ($process.ExitCode -ne 0) { throw "Cannot inventory Git project ${repository}: $errorText" }
            return $output.Split([char]0, [System.StringSplitOptions]::RemoveEmptyEntries)
        }
        finally { $process.Dispose() }
    }

    $tracked = @(Read-GitPaths @('ls-files', '-z', '--cached'))
    $untracked = @(Read-GitPaths @('ls-files', '-z', '--others', '--exclude-standard'))
    $paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    # These locations never contain project inputs, even if accidentally staged.
    $excluded = '(^|/)(\.git|node_modules|\.validation)(/|$)'
    # Tracked source takes precedence over these conventional output/cache names.
    $caches = '(^|/)(dist|coverage|\.next|\.turbo|\.pnpm-store|\.cache|__pycache__|\.pytest_cache|\.venv)(/|$)'
    foreach ($path in $tracked) {
        if ($path -notmatch $excluded) { [void]$paths.Add($path) }
    }
    foreach ($path in $untracked) {
        if ($path -notmatch $excluded -and $path -notmatch $caches) { [void]$paths.Add($path) }
    }
    foreach ($path in ($paths | Sort-Object)) {
        $full = Join-Path $repository $path
        # Deleted tracked files are not current inputs.
        if (Test-Path -LiteralPath $full -PathType Leaf) {
            Get-Item -LiteralPath $full -Force
        }
    }
}
