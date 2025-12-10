$requirementsFile = Join-Path $windowsFolder "requirements.txt"
if (Test-Path $requirementsFile){
    Write-Host "Installing dependencies"
    pip install --upgrade pip 
    pip install -r $requirementsFile
} else {
    Write-Host "No requirements.txt found."
}

