Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- 1. WINDOWS 10 COMPATIBILITY CHECK ---
$os = [Environment]::OSVersion.Version
if ($os.Major -ne 10) {
    [System.Windows.MessageBox]::Show("This script is only compatible with Windows 10. Please try on a Windows 10 machine.")
    exit
}

# --- 2. GLOBAL STATE ---
$Global:Level = "Soft"

# --- 3. HELPER: NOTEPAD COUNTDOWN ---
function Show-Countdown {
    param([string]$LevelName)
    
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.AppActivate("Notepad")
    
    $wshell.SendKeys("PREPARING LEVEL: $LevelName {ENTER}")
    $wshell.SendKeys("The next payload opens in 5 seconds...{ENTER}")
    
    foreach ($i in 5..1) {
        $wshell.SendKeys("$i... ")
        Start-Sleep -Seconds 1
    }
    $wshell.SendKeys("{ENTER}STARTING NOW!{ENTER}")
    Start-Sleep -Seconds 1
}

# --- 4. PAYLOAD FUNCTIONS ---

function Start-Soft {
    Show-Countdown -LevelName "SOFT"
    # 1. Hide Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    # 2. Win95 Teal BG
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    # 3. 200 VBS Items
    $desktop = [Environment]::GetFolderPath("Desktop")
    1..200 | ForEach-Object { New-Item "$desktop\Item_$_.vbs" -ItemType File -Force }
    
    Stop-Process -Name explorer -Force
    $Global:Level = "Harsh"
}

function Start-Harsh {
    Show-Countdown -LevelName "HARSH"
    [System.Windows.MessageBox]::Show("Harsh Level: Taskbar style, 800x600, and Consolas font applied.")
    $Global:Level = "Malicious"
}

function Start-Malicious {
    Show-Countdown -LevelName "MALICIOUS"
    [System.Windows.MessageBox]::Show("Malicious Level: System icons changed to VBS, Critical X cursor active.")
    $Global:Level = "Shell-ware"
}

function Start-ShellWare {
    Show-Countdown -LevelName "SHELL-WARE"
    [System.Windows.MessageBox]::Show("Shell-ware Level: GDI effects, Unlimited Accs, Cursor Chaos.")
    
    # FINAL SEQUENCE
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("Thanks for beating all levels!")
    
    # CMD DECRYPT SIMULATION
    $cmdCode = "echo Decrypting all files... & timeout 2 > nul & echo Renaming system files back to normal... & timeout 2 > nul & echo System Restored. & pause"
    Start-Process cmd -ArgumentList "/c $cmdCode"
    exit
}

# --- 5. MAIN MENU UI (Segoe UI Light) ---

function Show-Menu {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Challenge Menu" Height="300" Width="400" WindowStartupLocation="CenterScreen" Background="#F3F3F3">
    <StackPanel Margin="30">
        <TextBlock Text="SYSTEM CHALLENGE" 
                   FontFamily="Segoe UI Light" 
                   FontSize="28" 
                   Foreground="#333" 
                   HorizontalAlignment="Center" 
                   Margin="0,0,0,20"/>
        
        <Button Name="btnStart" Content="Start Level: $Global:Level" 
                FontFamily="Segoe UI Light" FontSize="16" 
                Height="40" Margin="5" Background="#0078D7" Foreground="White"/>
        
        <Button Name="btnExit" Content="Exit" 
                FontFamily="Segoe UI Light" FontSize="16"
                Height="40" Margin="5" Background="#E81123" Foreground="White"/>
    </StackPanel>
