@echo off
echo Fire Extinguisher Expiry Notification System - Test Runner
echo ======================================================
echo.

if "%1"=="" (
    echo Please specify a test scenario:
    echo.
    echo   all        - Test all notification scenarios
    echo   two-months - Test notifications for fire extinguishers expiring in 1-2 months
    echo   one-month  - Test notifications for fire extinguishers expiring within a month
    echo   critical   - Test notifications for fire extinguishers expiring within a week
    echo.
    echo Example: RunTests.bat all
    goto :eof
)

set SCENARIO=%1
if "%SCENARIO%"=="all" (
    echo Running all test scenarios...
    echo.
    cd bin\Debug
    ExpiryNotifications.exe --test
) else (
    echo Running test scenario: %SCENARIO%
    echo.
    cd bin\Debug
    ExpiryNotifications.exe --test --scenario %SCENARIO%
)
