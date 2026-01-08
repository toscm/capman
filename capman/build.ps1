param(
    [string]$CompilerPath,
    [string]$BasePath,
    [string]$Output = "capman.exe"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $scriptDir 'capman.ahk'
if (-not (Test-Path $source)) {
    throw "Cannot find capman.ahk next to build.ps1."
}

if ([System.IO.Path]::IsPathRooted($Output)) {
    $outFile = $Output
} else {
    $outFile = Join-Path $scriptDir $Output
}

$compilerCandidates = @()
if ($CompilerPath) {
    $compilerCandidates += $CompilerPath
}

$ahkFromPath = Get-Command 'Ahk2Exe.exe' -ErrorAction SilentlyContinue
if ($ahkFromPath) {
    $compilerCandidates += $ahkFromPath.Path
}

$compiler = $compilerCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $compiler) {
    throw "Ahk2Exe.exe not found in PATH. Install AutoHotkey v2, add Ahk2Exe.exe to PATH, or pass -CompilerPath."
}

$baseCandidates = @()
if ($BasePath) {
    $baseCandidates += $BasePath
}

$autoHotkey = Get-Command 'AutoHotkey64.exe' -ErrorAction SilentlyContinue
if ($autoHotkey) {
    $baseCandidates += $autoHotkey.Path
}

$base = $baseCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $base) {
    throw "AutoHotkey64.exe not found in PATH. Install AutoHotkey v2, add AutoHotkey64.exe to PATH, or pass -BasePath."
}

Write-Host "Compiling $source -> $outFile" -ForegroundColor Cyan

$arguments = @(
    '/in', $source,
    '/out', $outFile,
    '/base', $base
)

& $compiler @arguments
$exitCode = $LASTEXITCODE
if ($null -eq $exitCode) {
    $exitCode = 0
}
if ($exitCode -ne 0) {
    throw "Compilation failed with exit code $exitCode."
}

if (-not (Test-Path $outFile)) {
    throw "Compilation finished without creating $outFile."
}

Write-Host "Build succeeded: $outFile" -ForegroundColor Green
