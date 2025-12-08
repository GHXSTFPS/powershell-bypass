# powershell-bypass
lscsicpl.exe UAC bypass in duckyscript  

 These instructions pop us into a elevated UAC bypassed powershell  
 Reference point is https://lolbas-project.github.io/lolbas/Binaries/Iscsicpl/#uac bypass  
 Leverages c:\windows\syswow64\iscsicpl.exe to elevate powershell  

## Futue Ideas

- Incorporate DeadDrop.ps1 either functionality or litterally (SSH)
- Exfiltration (Registry Hives, Browser Data, Password Manager DB's, Wifi conf)
- Persistence
- VNC Viewing (RAT Functionality)
- Keylogging
- instead of just writing powershell in the report > file explorer we can maybe treat it like a run prompt and run a script to save time asw as visibility by running -WindowType Hidden
- Add functionality to close all windows opened automatically and clear powershell logs and registry entries
