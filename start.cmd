@echo off
rem Starts KrabbzDev's Porch Radar from source (needs Node.js) and opens it in your browser.
cd /d "%~dp0"
start "" http://localhost:8090
node server.js
