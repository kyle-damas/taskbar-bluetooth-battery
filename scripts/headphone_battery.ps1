Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create a text-only icon with larger text
function Create-TextIcon {
    param ([int]$percentage)

    $bitmap = New-Object System.Drawing.Bitmap 32,32
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $brush = New-Object Drawing.SolidBrush([System.Drawing.Color]::Black)
    $font = New-Object System.Drawing.Font("Arial", 20)

    # Draw percentage text
    if ($percentage -lt 100) {
        $graphics.DrawString($percentage.ToString(), $font, $brush, -4, 0)
    } else {
        $font = New-Object System.Drawing.Font("Arial", 14)
		$graphics.DrawString("100", $font, $brush, -6, 4)
    }

    $graphics.Dispose()
    return $bitmap
}

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true

# Variable to store the last known battery level
$script:lastBatteryLevel = $null

function Get-HeadphoneBattery {
    $device = Get-PnpDevice -FriendlyName '*soundcore Liberty 4 Hands-Free AG*' | Select-Object @{L="Battery";E={(Get-PnpDeviceProperty -DeviceID $_.PNPDeviceID -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2').Data}}
    return $device.Battery
}

function Update-BatteryNotification {
    $battery = Get-HeadphoneBattery
    if ($battery -ne $null) {
        $icon = Create-TextIcon -percentage $battery
        $notifyIcon.Icon = [System.Drawing.Icon]::FromHandle($icon.GetHicon())
        $notifyIcon.Text = "Soundcore Liberty 4: $battery%"

        # Only show balloon tip if battery level has changed
        if ($battery -ne $script:lastBatteryLevel) {
            $notifyIcon.BalloonTipTitle = "Headphone Battery"
            $notifyIcon.BalloonTipText = "Battery level changed to: $battery%"
            $notifyIcon.ShowBalloonTip(5000)
            $script:lastBatteryLevel = $battery
        }
    } else {
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Error
        $notifyIcon.Text = "Soundcore Liberty 4: Not connected"
        
        # Show disconnection notification only if it was previously connected
        if ($script:lastBatteryLevel -ne $null) {
            $notifyIcon.BalloonTipTitle = "Headphone Disconnected"
            $notifyIcon.BalloonTipText = "Soundcore Liberty 4 is no longer connected"
            $notifyIcon.ShowBalloonTip(5000)
            $script:lastBatteryLevel = $null
        }
    }
}

# Create a timer to update the battery status every 5 minutes
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300000 # 5 minutes in milliseconds
$timer.Add_Tick({ Update-BatteryNotification })
$timer.Start()

# Initial update
Update-BatteryNotification

# Create an application context and run it
$appContext = New-Object System.Windows.Forms.ApplicationContext
[System.Windows.Forms.Application]::Run($appContext)
