@echo off
title Task 3 - Incident Recovery and Blue-Green Deployment
cd /d "%~dp0"
echo ================================================================================
echo   TASK 3: PRODUCTION INCIDENT RECOVERY & BLUE-GREEN ZERO-DOWNTIME DEPLOYMENT
echo ================================================================================

echo.
echo [1] Running Unit Tests Directly...
node task3-orders-blue-green\tests\orders.test.js

echo.
echo [2] Simulating Successful 12-Stage Blue-Green Zero-Downtime Deployment...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task3.ps1" -TargetVersion "7.9.0" -ConfirmProd "YES"

echo.
echo [3] Simulating Candidate Health Failure & Production Traffic Safeguard...
powershell -ExecutionPolicy Bypass -File "scripts\simulate-pipeline-task3.ps1" -TargetVersion "7.9.0" -ConfirmProd "YES" -InjectFailure

echo.
echo ================================================================================
echo Task 3 completed. Press any key to exit...
pause >nul
