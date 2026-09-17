@echo off
REM Convenience wrapper so the export can be started by double-click on the
REM server. Any extra arguments are passed straight to the PowerShell script.
REM
REM   run-export.cmd -DryRun
REM   run-export.cmd -TopSites 8 -Months 3
REM   run-export.cmd -SiteNo 999_S2,2800_S2 -Months 6

setlocal
set SCRIPT=%~dp0Export-MashrSeed.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
echo.
pause
