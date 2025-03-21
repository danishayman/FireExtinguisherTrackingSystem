@ECHO OFF
ECHO Fire Extinguisher Tracking System - Service Reminder Setup
ECHO ====================================================
ECHO.
ECHO This script will add the DateServiced column to the FireExtinguishers table
ECHO and create the ServiceReminders table to enable follow-up reminder emails.
ECHO.

SET /P CONTINUE=Do you want to continue? (Y/N): 
IF /I "%CONTINUE%" NEQ "Y" GOTO END

ECHO.
ECHO Running database updates...
ECHO.

REM Set your SQL Server connection details here
SET SERVER=localhost
SET DATABASE=FETS
SET USERNAME=irfandanish
SET PASSWORD=1234

REM Run the SQL script through SQLCMD
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -i DB_Updates.sql

IF %ERRORLEVEL% NEQ 0 (
    ECHO.
    ECHO Error executing SQL script. Please check your connection details and try again.
    GOTO END
)

ECHO.
ECHO Database updated successfully!
ECHO.
ECHO The following changes were made:
ECHO  - Added DateServiced column to FireExtinguishers table
ECHO  - Created ServiceReminders table to track follow-up reminders
ECHO  - Added index to optimize reminder queries
ECHO.
ECHO Next steps:
ECHO  1. Make sure the ExpiryNotifications service is configured to run daily
ECHO  2. Test the service reminder functionality using the test mode
ECHO     (ExpiryNotifications.exe --test --scenario service)
ECHO.

:END
PAUSE 