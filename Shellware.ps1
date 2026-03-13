Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- OS CHECK ---
if ([Environment]::OSVersion.Version.Major -ne 10) {
    [System.Windows.MessageBox]::Show("This script is only compatible with Windows 10.")
    exit
}

# --- GLOBAL STATE ---
$Global:Level = "Soft"

# --- HELPER: NOTEPAD COUNTDOWN ---
function Show-Countdown {
    param([string]$LevelName)
    
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.AppActivate("Notepad")
    
    $wshell.SendKeys("PREPARING LEVEL: $LevelName {ENTER}")
    $wshell.SendKeys("The next payload starts in...{ENTER}")
    
    foreach ($i in 5..1) {
        $wshell.SendKeys("$i... ")
        Start-Sleep -Seconds 1
    }
    $wshell.SendKeys("{ENTER}STARTING NOW!{ENTER}")
    Start-Sleep -Seconds 1
}

# --- PAYLOADS ---

function Start-Soft {
    Show-Countdown -LevelName "SOFT"
    # 1. Hide Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    # 2. Win95 Teal
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    # 3. 200 VBS Items
    $desktop = [Environment]::GetFolderPath("Desktop")
    1..200 | ForEach-Object { New-Item "$desktop\Item_$_.vbs" -ItemType File -Force }
    
    Stop-Process -Name explorer -Force
    $Global:Level = "Harsh"
}

function Start-Harsh {
    Show-Countdown -LevelName "HARSH"
    [System.Windows.MessageBox]::Show("Payload: Win 8 Taskbar, 800x600 Res, Consolas Font (Simulated)")
    $Global:Level = "Malicious"
}

function Start-Malicious {
    Show-Countdown -LevelName "MALICIOUS"
    [System.Windows.MessageBox]::Show("Payload: VBS Icons, Gibberish Files, Critical X Cursor (Simulated)")
    $Global:Level = "Shell-ware"
}

function Start-ShellWare {
    Show-Countdown -LevelName "SHELL-WARE"
    [System.Windows.MessageBox]::Show("Payload: GDI Melting, Unlimited Accs, Cursor Chaos (Simulated)")
    
    # Ending Sequence
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("Thanks for beating all levels!")
    
    Start-Process cmd -ArgumentList "/k echo Decrypting all files... && timeout 2 && echo Renaming system files and icons back to normal... && timeout 2 && echo System Restored."
    exit
}

# --- MAIN MENU UI ---
function Show-Menu {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Challenge Menu" Height="300" Width="400" WindowStartupLocation="CenterScreen" Background="#111">
    <StackPanel Margin="30">
        <TextBlock Text="MAIN MENU" Foreground="White" FontSize="24" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        <Button Name="btnStart" Content="Start Level: $Global:Level" Height="40" Margin="5"/>
        <Button Name="btnExit" Content="Exit" Height="40" Margin="5" Background="#552222" Foreground="White"/>
    </StackPanel>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    
    $btnStart = $window.FindName("btnStart")
    $btnExit = $window.FindName("btnExit")

    $btnExit.Add_Click({ $window.Close(); exit })

    $btnStart.Add_Click({
        $window.Close()
        if ($Global:Level -eq "Soft") { Start-Soft }
        elseif ($Global:Level -eq "Harsh") { Start-Harsh }
        elseif ($Global:Level -eq "Malicious") { Start-Malicious }
        elseif ($Global:Level -eq "Shell-ware") { Start-ShellWare }
        Show-Menu
    })

    $window.ShowDialog() | Out-Null
}

Show-Menu
