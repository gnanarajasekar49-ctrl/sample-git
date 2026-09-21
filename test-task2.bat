@echo off
title Task 2 - Multi-Environment CI/CD
cd /d "%~dp0"
echo ================================================================================
echo   TASK 2: MULTI-ENVIRONMENT CI/CD WITH DOCKER NETWORK & STORAGE ISOLATION
echo ================================================================================

echo.
echo [1] Running Multi-Environment Git Strategy...
powershell -ExecutionPolicy Bypass -File "scripts\git-workflow-task2.ps1"

echo.
echo [2] Running Unit Tests Directly...
node task2-customer-service\tests\customer.test.js

echo.
echo [3] Deploying DEV Environment (Port 8081)...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task2.ps1" -Environment "DEV" -Version "5.0.0"

echo.
echo [4] Deploying UAT Environment (Port 8082)...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task2.ps1" -Environment "UAT" -Version "5.0.0"

echo.
echo [5] Deploying PRODUCTION with 8-Point Validation (Port 8083)...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task2.ps1" -Environment "PRODUCTION" -Version "5.0.0" -ConfirmProd "YES"

echo.
echo [6] Simulating Database Failure & Automated Rollback...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task2.ps1" -Environment "PRODUCTION" -Version "5.1.0-fail" -ConfirmProd "YES"

echo.
echo ================================================================================
echo Task 2 completed. Press any key to exit...
pause >nul
