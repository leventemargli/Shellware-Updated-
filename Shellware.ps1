Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- 1. COMPATIBILITY CHECK ---
# Checks for Windows 10 (10.0) or Windows 8.1 (6.3)
$os = [Environment]::OSVersion.Version
if (!($os.Major -eq 10 -or ($os.Major -eq 6 -and $os.Minor -eq 3))) {
    $msg = "This script is only compatible with Windows 8.1 or Windows 10. `n" +
           "Please try this script on a virtual machine that has Windows 8."
    [System.Windows.MessageBox]::Show($msg, "Incompatible OS")
    exit
}

# --- 2. GLOBAL STATE ---
$Global:Level = "Soft"
$Global:Desktop = [Environment]::GetFolderPath("Desktop")

# --- 3. HELPER: NOTEPAD AUTOMATION ---
function Show-Countdown {
    param([string]$LvlName)
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.AppActivate("Notepad")
    $wshell.SendKeys("CHALLENGE INITIALIZED: $LvlName {ENTER}")
    $wshell.SendKeys("Next payload triggers in 5 seconds...{ENTER}")
    foreach ($i in 5..1) {
        $wshell.SendKeys("$i... ")
        Start-Sleep -Milliseconds 800
    }
    $wshell.SendKeys("{ENTER}--- DEPLOYING ---{ENTER}")
    Start-Sleep -Seconds 1
}

# --- 4. LEVEL PAYLOADS ---

function Start-Soft {
    Show-Countdown -LvlName "SOFT"
    # Payload 1: Hide Desktop Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    # Payload 2: Win95 Teal Background
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    # Payload 3: 200 VBS Items
    1..200 | ForEach-Object { 
        $path = Join-Path $Global:Desktop "Challenge_Item_$_.vbs"
        "MsgBox ""Level Soft"",0,""System""" | Out-File $path -Encoding ascii 
    }
    Stop-Process -Name explorer -Force
    $Global:Level = "Harsh"
}

function Start-Harsh {
    Show-Countdown -LvlName "HARSH"
    # Simulated Payloads (Resolution/Font)
    [System.Windows.MessageBox]::Show("Harsh: Taskbar updated, Res: 800x600, Font: Consolas.")
    $Global:Level = "Malicious"
}

function Start-Malicious {
    Show-Countdown -LvlName "MALICIOUS"
    # Simulated Payloads (Icons/Filenames)
    [System.Windows.MessageBox]::Show("Malicious: Icons swapped, Files renamed to gibberish,
