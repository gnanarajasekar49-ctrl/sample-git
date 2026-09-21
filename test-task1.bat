@echo off
title Task 1 - Enterprise Release and Rollback
cd /d "%~dp0"
echo ================================================================================
echo   TASK 1: ENTERPRISE RELEASE, HOTFIX, AND AUTOMATED ROLLBACK
echo ================================================================================

echo.
echo [1] Running Git Branching, Tagging, and Conflict Resolution...
powershell -ExecutionPolicy Bypass -File "scripts\git-workflow-task1.ps1"

echo.
echo [2] Running Unit Tests Directly...
node task1-retail-platform\tests\app.test.js

echo.
echo [3] Simulating Successful Deployment of v4.2.1...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task1.ps1" -Version "4.2.1" -ConfirmProd "YES"

echo.
echo [4] Simulating Mandatory Failure Injection (v4.2.2) and Automatic Rollback...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task1.ps1" -Version "4.2.2" -ConfirmProd "YES"

echo.
echo ================================================================================
echo Task 1 completed. Press any key to exit...
pause >nul

