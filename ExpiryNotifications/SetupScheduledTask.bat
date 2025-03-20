@echo off
echo Setting up Scheduled Task for Fire Extinguisher Expiry Notifications
echo ================================================================
echo.

set TASK_NAME="Fire Extinguisher Expiry Check"
set EXE_PATH="%~dp0bin\Debug\ExpiryNotifications.exe"
set START_TIME=07:00

echo Task Name: %TASK_NAME%
echo Executable: %EXE_PATH%
echo Start Time: %START_TIME% daily
echo.

echo Creating scheduled task...
schtasks /create /tn %TASK_NAME% /tr %EXE_PATH% /sc DAILY /st %START_TIME% /ru SYSTEM

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Scheduled task created successfully!
    echo The application will run daily at %START_TIME%.
) else (
    echo.
    echo Failed to create scheduled task. Error code: %ERRORLEVEL%
    echo Please try running this script as Administrator.
)

echo.
echo Press any key to exit...
pause > nul
