Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- 1. WINDOWS 10 COMPATIBILITY CHECK ---
$os = [Environment]::OSVersion.Version
if ($os.Major -ne 10) {
    [System.Windows.MessageBox]::Show("This script is optimized for Windows 10. Please run on a Win10 machine or VM.")
    exit
}

# --- 2. GLOBAL STATE ---
$Global:Level = "Soft"

# --- 3. PAYLOAD LOGIC ---

function Start-Soft {
    # 1. Hide Desktop Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    # 2. Win95 Teal Background
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    # 3. 200 VBS Items
    $desktop = [Environment]::GetFolderPath("Desktop")
    1..200 | ForEach-Object { New-Item "$desktop\Challenge_$_.vbs" -ItemType File -Force }
    
    Stop-Process -Name explorer -Force # Refresh to apply changes
    $Global:Level = "Harsh"
}

function Start-Harsh {
    # 1. Taskbar/Font Simulation (Consolas)
    # 2. Resolution Simulation (800x600)
    [System.Windows.MessageBox]::Show("Harsh Level: Taskbar style changed, Font set to Consolas, Resolution 800x600.")
    $Global:Level = "Malicious"
}

function Start-Malicious {
    # 1. Icon/Cursor Simulation
    [System.Windows.MessageBox]::Show("Malicious Level: Icons swapped to VBS, Cursor set to Critical X.")
    $Global:Level = "Shell-ware"
}

function Start-ShellWare {
    # 1. GDI / Effect Simulation
    [System.Windows.MessageBox]::Show("Shell-ware Level: Melting GDI effects and Cursors active.")
    
    # FINAL SEQUENCE
    Start-Process notepad
    Start-Sleep -Seconds 2
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("Thanks for beating all levels!")
    
    # CMD DECRYPT SIMULATION
    $cmdCode = "echo Decrypting all files... & timeout 2 > nul & echo Renaming system files back to normal... & timeout 2 > nul & echo System Restored. & pause"
    Start-Process cmd -ArgumentList "/c $cmdCode"
    
    exit
}

# --- 4. MAIN MENU UI ---

function Show-Menu {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Main Menu" Height="300" Width="400" WindowStartupLocation="CenterScreen" Background="#121212">
    <StackPanel Margin="30">
        <TextBlock Text="SYSTEM CHALLENGE" Foreground="Cyan" FontSize="22" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        <Button Name="btnStart" Content="Start Level: $Global:Level" Height="40" Margin="5"/>
        <Button Name="btnExit" Content="Exit" Height="40" Margin="5" Background="#442222" Foreground="White"/>
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
        Show-Menu # Refresh menu for next level
    })

    $window.ShowDialog() | Out-Null
}

# --- EXECUTION ---
Show-Menu
