@echo off
:: WarVM automated post-install script
:: Runs once on first boot via the dockurr/windows OEM hook

echo [WarVM] Starting automated software installation...

:: ---- Wait for network ----
:WAITNET
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto WAITNET
)
echo [WarVM] Network is up.

:: ---- Install winget if not present (Win11 should have it, but just in case) ----
where winget >nul 2>&1
if errorlevel 1 (
    echo [WarVM] Installing winget...
    powershell -Command "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
)

:: ---- Install Google Chrome ----
echo [WarVM] Installing Google Chrome...
winget install --id Google.Chrome -e --accept-source-agreements --accept-package-agreements --silent
if errorlevel 1 (
    :: Fallback: direct download
    powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe'"
    "%TEMP%\chrome_installer.exe" /silent /install
)
echo [WarVM] Chrome installed.

:: ---- Install War Thunder launcher (Gaijin.Net Launcher) ----
echo [WarVM] Downloading War Thunder launcher...
powershell -Command "Invoke-WebRequest -Uri 'https://launcher.gaijin.net/download/warthunder' -OutFile '%TEMP%\wt_launcher.exe' -UserAgent 'Mozilla/5.0'"
if exist "%TEMP%\wt_launcher.exe" (
    "%TEMP%\wt_launcher.exe" /S
    echo [WarVM] War Thunder launcher installed.
) else (
    echo [WarVM] WARNING: War Thunder launcher download failed - please install manually.
)

:: ---- Create desktop shortcuts ----
powershell -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\War Thunder.lnk'); ^
   $s.TargetPath = [Environment]::GetFolderPath('ProgramFiles') + '\Gaijin\War Thunder\launcher.exe'; ^
   $s.Save()"

:: ---- Set Chrome as default browser ----
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name ProgId -Value 'ChromeHTML' -Force" 2>nul

:: ---- Performance tweaks for VM ----
powershell -Command ^
  "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name VisualFXSetting -Value 2; ^
   Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name MenuShowDelay -Value 0"

:: ---- Disable Windows Update auto-restart ----
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f

echo [WarVM] Setup complete! Desktop shortcuts created.
echo [WarVM] Please launch War Thunder from the desktop and log in.
