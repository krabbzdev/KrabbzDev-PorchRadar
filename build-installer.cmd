@echo off
rem Builds and signs the Windows installer (dist\Krabbz9999-FlightTracker-Setup.exe).
rem Only needed when the launcher, tray helper, installer or bundled Node.js changes; normal releases are code-only (release.cmd).
rem   build-installer.cmd            build and sign (open your code-signing app and sign in first)
rem   build-installer.cmd -Upload    ...and publish it to the "installer" release
rem   build-installer.cmd -NoSign    build unsigned, for testing
rem Details: scripts\build-installer.ps1
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build-installer.ps1" %*
exit /b %ERRORLEVEL%
