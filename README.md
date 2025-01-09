# Description
This script runs on Windows 11 and provides the battery percentage for a Bluetooth device (headset) in a taskbar notification.  

Example of what it looks like in the Taskbar when the mouse hovers over the icon (battery percentage):  

<img src="screenshots/screenshot.png">

#### Configuration required
1. Save `headphone_battery.ps1` and `RunHiddenHeadphoneBattery.vbs` somewhere on your hard drive.
2. Save `RunHiddenHeadphoneBattery.bat` in your Windows Startup directory. To find the Windows Startup location, go to Start -> Run -> and then type in `shell:startup` and hit enter.
3. Modify `RunHiddenHeadphoneBattery.bat` and update the path to `RunHiddenHeadphoneBattery.vbs` based on where you saved it in step #1. Modify `RunHiddenHeadphoneBattery.vbs` and update the path to `headphone_battery.ps1` based on where you saved it in step #1.
4. You'll need to update `headphone_battery.ps1` with your Bluetooth device name. To find the correct Bluetooth device name, run this command via PowerShell:
> NOTE: You might see your PowerShell session flash a blue bar at the top. You can ignore that. It's just cycling through the list of devices.
```
$devices = Get-PnpDevice | 
    Where-Object { $_.InstanceId -like "*BTHENUM*" -or $_.Class -eq 'Bluetooth' } | 
    Select-Object FriendlyName, InstanceId, Class

$devices | ForEach-Object {
    $batteryLevel = $null
    $batteryProperty = Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue

    if ($batteryProperty -and $batteryProperty.Data) {
        $batteryLevel = $batteryProperty.Data
        
        [PSCustomObject]@{
            FriendlyName = $_.FriendlyName
            Class = $_.Class
            BatteryLevel = "$batteryLevel%"
        }
    }
} | Where-Object { $_.BatteryLevel -ne $null } | Format-Table -AutoSize -Wrap
```
The output should look something like this:
```
FriendlyName                            Class  BatteryLevel
------------                            -----  ------------
soundcore Liberty 4 Hands-Free AG       System 80%
Soundcore Liberty Air 2-L Hands-Free AG System 80%
Echo Buds HKQX Hands-Free AG            System 99%
Soundcore Liberty Air 2 Hands-Free AG   System 100%
```
You'll need to update line 33 from `headphone_battery.ps1` changing `soundcore Liberty 4 Hands-Free AG` to whatever the `FriendlyName` is for the device you want to track the Bluetooth battery percentage. You should also update lines 42, 53, and 58 to whatever you want the notification to call your device. In my example, I called it `Soundcore Liberty 4`.
