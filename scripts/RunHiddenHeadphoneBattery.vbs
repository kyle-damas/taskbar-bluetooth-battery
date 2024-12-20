Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File ""C:\Users\<user>\headphone_battery.ps1""", 0, False
