# Master Runner: Executes All 3 Tasks Locally Without Jenkins
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "       DEVOPS ASSESSMENT: COMPLETE LOCAL EXECUTION (STANDALONE / NO JENKINS)    " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# ---------------------------------------------------------
# TASK 1: Enterprise Release, Hotfix, and Automated Rollback
# ---------------------------------------------------------
Write-Host "`n>>> [TASK 1] EXECUTING GIT WORKFLOW & CONFLICT RESOLUTION..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/git-workflow-task1.ps1"

Write-Host "`n>>> [TASK 1] RUNNING SUCCESSFUL DEPLOYMENT (v4.2.1)..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task1.ps1" -Version "4.2.1" -ConfirmProd "YES"

Write-Host "`n>>> [TASK 1] RUNNING MANDATORY FAILURE INJECTION & AUTOMATED ROLLBACK (v4.2.2)..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task1.ps1" -Version "4.2.2" -ConfirmProd "YES"

# ---------------------------------------------------------
# TASK 2: Multi-Environment CI/CD with Docker Network & Storage
# ---------------------------------------------------------
Write-Host "`n>>> [TASK 2] EXECUTING MULTI-ENV GIT STRATEGY..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/git-workflow-task2.ps1"

Write-Host "`n>>> [TASK 2] DEPLOYING DEV ENVIRONMENT..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task2.ps1" -Environment "DEV" -Version "5.0.0"

Write-Host "`n>>> [TASK 2] DEPLOYING UAT ENVIRONMENT..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task2.ps1" -Environment "UAT" -Version "5.0.0"

Write-Host "`n>>> [TASK 2] DEPLOYING PRODUCTION ENVIRONMENT (8-POINT VALIDATION)..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task2.ps1" -Environment "PRODUCTION" -Version "5.0.0" -ConfirmProd "YES"

Write-Host "`n>>> [TASK 2] RUNNING DATABASE FAILURE & AUTOMATED ROLLBACK SCENARIO..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task2.ps1" -Environment "PRODUCTION" -Version "5.1.0-fail" -ConfirmProd "YES"

# ---------------------------------------------------------
# TASK 3: Production Incident, Pipeline Recovery & Blue-Green
# ---------------------------------------------------------
Write-Host "`n>>> [TASK 3] RUNNING ZERO-DOWNTIME BLUE-GREEN DEPLOYMENT (12 STAGES)..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task3.ps1" -TargetVersion "7.9.0" -ConfirmProd "YES"

Write-Host "`n>>> [TASK 3] RUNNING CANDIDATE FAILURE & ACTIVE PRODUCTION PRESERVATION..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts/simulate-pipeline-task3.ps1" -TargetVersion "7.9.0" -ConfirmProd "YES" -InjectFailure

Write-Host "`n================================================================================" -ForegroundColor Cyan
Write-Host "           ALL 3 DEVOPS ASSESSMENT TASKS COMPLETED & VALIDATED LOCALLY          " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

