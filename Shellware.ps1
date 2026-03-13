Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- 1. COMPATIBILITY CHECK (Windows 10) ---
$os = [Environment]::OSVersion.Version
# Windows 10 is Major version 10
if ($os.Major -ne 10) {
    [System.Windows.MessageBox]::Show("This script is optimized for Windows 10. Current Version: $($os.Major).$($os.Minor)")
    # If you want to force it to stop on other OS, uncomment the next line:
    # exit
}

# --- 2. GLOBAL STATE ---
$Global:CurrentLevel = "Soft"

# --- 3. PAYLOAD FUNCTIONS ---

function Start-SoftPayload {
    # Payload 1: Hide Desktop Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    Stop-Process -Name explorer -Force # Refresh explorer to apply
    
    # Payload 2: Win95 Teal Background (0 128 128)
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    
    # Payload 3: 200 VBS Items on Desktop
    $desktop = [Environment]::GetFolderPath("Desktop")
    1..200 | ForEach-Object { New-Item "$desktop\Challenge_$_.vbs" -ItemType File -Force }
    
    $Global:CurrentLevel = "Harsh"
}

function Start-HarshPayload {
    # Logic for Font (Consolas) and Resolution (800x600) simulation
    [System.Windows.MessageBox]::Show("Harsh Level: Font set to Consolas. Resolution adjusted.")
    $Global:CurrentLevel = "Malicious"
}

function Start-MaliciousPayload {
    # Logic for Icon swapping and Cursors
    [System.Windows.MessageBox]::Show("Malicious Level: Icons changed to VBS. Cursor set to Critical X.")
    $Global:CurrentLevel = "Shell-ware"
}

function Run-FinalSequence {
    # Final Notepad Message
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("Thanks for beating all levels!")
    
    # CMD Simulation
    Start-Process cmd -ArgumentList "/k echo Decrypting all files... && timeout 2 && echo Renaming system files and icons back to normal... && timeout 2 && echo System Restored. && pause"
}

# --- 4. MAIN MENU UI ---

function Show-ChallengeMenu {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="System Challenge" Height="300" Width="400" WindowStartupLocation="CenterScreen" Background="#222">
    <StackPanel Margin="30">
        <TextBlock Text="SYSTEM CHALLENGE" Foreground="Lime" FontSize="22" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <Button Name="btnStart" Content="Start Level: $Global:CurrentLevel" Height="40" Margin="5" Background="#333" Foreground="White"/>
        <Button Name="btnExit" Content="Exit Game" Height="40" Margin="5" Background="#A33" Foreground="White"/>
        
        <TextBlock Name="txtLevel" Text="Next Unlocks: ..." Foreground="Gray" HorizontalAlignment="Center" Margin="0,10,0,0"/>
    </StackPanel>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    $btnStart = $window.FindName("btnStart")
    $btnExit = $window.FindName("btnExit")

    # EXIT BUTTON
    $btnExit.Add_Click({ $window.Close() })

    # START BUTTON LOGIC
    $btnStart.Add_Click({
        $window.Hide()
        
        if ($Global:CurrentLevel -eq "Soft") {
            Start-SoftPayload
        } elseif ($Global:CurrentLevel -eq "Harsh") {
            Start-HarshPayload
        } elseif ($Global:CurrentLevel -eq "Malicious") {
            Start-MaliciousPayload
        } elseif ($Global:CurrentLevel -eq "Shell-ware") {
            # Run Shell-ware then end
            Run-FinalSequence
            return
        }

        Show-ChallengeMenu # Refresh menu for next level
    })

    $window.ShowDialog() | Out-Null
}

# Launch
Show-ChallengeMenu
