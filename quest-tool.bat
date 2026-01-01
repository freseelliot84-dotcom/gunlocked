@echo off
color 0C
title Quest Tool by Silent

:check_adb
where adb >nul 2>&1
if errorlevel 1 (
    echo ADB not found. Please install ADB and add it to PATH.
    pause
    exit /b
)

:ascii_banner
cls
echo.
echo  ░██████╗░██╗░░░██╗███╗░░██╗██╗░░░░░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
echo  ██╔════╝░██║░░░██║████╗░██║██║░░░░░██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
echo  ██║░░██╗░██║░░░██║██╔██╗██║██║░░░░░██║░░██║██║░░╚═╝█████═╝░█████╗░░██║░░██║
echo  ██║░░╚██╗██║░░░██║██║╚████║██║░░░░░██║░░██║██║░░██╗██╔═██╗░██╔══╝░░██║░░██║
echo  ╚██████╔╝╚██████╔╝██║░╚███║███████╗╚█████╔╝╚█████╔╝██║░╚██╗███████╗██████╔╝
echo  ░╚═════╝░░╚═════╝░╚═╝░░╚══╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚══════╝╚═════╝░
echo.
echo Quest Terminal Tool - By Silent
echo -------------------------------------------

:menu
echo.
echo Select an option:
echo 1) Set FPS / Swap Interval
echo 2) Check current FPS / Swap Interval
echo 3) Connect Quest Wirelessly (auto-detect IP)
echo Q) Quit
set /p choice=Choice: 

if /i "%choice%"=="1" goto set_fps
if /i "%choice%"=="2" goto check_settings
if /i "%choice%"=="3" goto wireless
if /i "%choice%"=="Q" goto quit
goto menu

:set_fps
cls
echo Choose FPS:
echo 1) 72
echo 2) 80
echo 3) 90
echo 4) 120
echo 5) Custom (1-200)
set /p fps_choice=Select option (1-5): 
if "%fps_choice%"=="1" set FPS=72
if "%fps_choice%"=="2" set FPS=80
if "%fps_choice%"=="3" set FPS=90
if "%fps_choice%"=="4" set FPS=120
if "%fps_choice%"=="5" (
    set /p FPS=Enter custom FPS (1-200):
)
set /p SWAP=Enter Swap Interval (0-5, default 1):
if "%SWAP%"=="" set SWAP=1

echo You selected: FPS=%FPS%, Swap Interval=%SWAP%
set /p CONFIRM=Apply these settings? (y/n):
if /i "%CONFIRM%"=="y" (
    goto apply_settings
) else (
    goto menu
)

:apply_settings
cls
echo Applying settings...
adb shell setprop debug.oculus.refreshRate %FPS%
adb shell setprop debug.oculus.swapInterval %SWAP%
echo Settings applied!
echo FPS: %FPS%
echo Swap Interval: %SWAP%
pause
goto menu

:check_settings
cls
echo Checking current Quest settings...
for /f "tokens=*" %%a in ('adb shell getprop debug.oculus.refreshRate') do set current_fps=%%a
for /f "tokens=*" %%b in ('adb shell getprop debug.oculus.swapInterval') do set current_swap=%%b
echo Current Refresh Rate: %current_fps%
echo Current Swap Interval: %current_swap%
pause
goto menu

:wireless
cls
echo Detecting USB Quest...
for /f "tokens=1" %%d in ('adb devices ^| findstr /R /C:"device$" ^| findstr /V "emulator"') do set USB_DEVICE=%%d
if "%USB_DEVICE%"=="" (
    echo No USB Quest detected. Connect your Quest via USB first.
    pause
    goto menu
)
echo Detected USB Quest: %USB_DEVICE%
adb -s %USB_DEVICE% tcpip 5555
timeout /t 1 >nul
for /f "tokens=2 delims=:" %%i in ('adb -s %USB_DEVICE% shell ip addr show wlan0 ^| findstr "inet "') do set QUEST_IP=%%i
set QUEST_IP=%QUEST_IP: =%
if "%QUEST_IP%"=="" (
    echo Failed to get IP. Make sure Wi-Fi is enabled.
    pause
    goto menu
)
echo Connecting wirelessly to %QUEST_IP%...
adb connect %QUEST_IP%:5555
timeout /t 1 >nul
echo Wireless connection established!
pause
goto menu

:quit
exit
