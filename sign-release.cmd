@echo off
rem Signs the newest draft release with the Certum certificate and publishes it. See sign-release.ps1.
rem Usage:  sign-release.cmd            (the newest draft)
rem         sign-release.cmd v1.0.69    (a specific release)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sign-release.ps1" %*
