@echo off
title DevOps Assessment - Master Execution
cd /d "%~dp0"
echo ================================================================================
echo        DEVOPS ASSESSMENT: MASTER RUNNER (CMD / STANDALONE)
echo ================================================================================
powershell -ExecutionPolicy Bypass -File "scripts\run-all-tasks.ps1"
echo ================================================================================
echo Finished execution. Press any key to exit...
pause >nul

