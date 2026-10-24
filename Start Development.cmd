@echo off
cd /d "%~dp0"
python tools\start_sync.py
if errorlevel 1 pause
