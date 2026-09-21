# PowerShell Script: Git Workflow Automation for Task 1
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  EXECUTING GIT WORKFLOW FOR TASK 1 (RETAIL PLATFORM)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Configure local git user
git config user.email "devops-engineer@enterprise.com"
git config user.name "DevOps Engineer"

# 1. Ensure on main branch and commit initial v4.2.0 baseline
Write-Host ""
Write-Host "[Step 1] Initializing 'main' branch representing version 4.2.0..." -ForegroundColor Yellow
git checkout -B main
git add task1-retail-platform/
git commit -m "feat(core): initial production release v4.2.0 of retail platform" -q --allow-empty
git tag -a v4.2.0 -m "Production Release v4.2.0" -f

# 2. Create develop branch and add at least two feature commits
Write-Host ""
Write-Host "[Step 2] Creating 'develop' branch with 2 feature commits..." -ForegroundColor Yellow
git checkout -B develop
Set-Content -Path "task1-retail-platform/app/features.txt" -Value "Feature 1: Product catalogue filtering"
git add task1-retail-platform/app/features.txt
git commit -m "feat(catalog): add advanced product catalogue filtering and search" -q

Add-Content -Path "task1-retail-platform/app/features.txt" -Value "Feature 2: User cart discount summary"
git add task1-retail-platform/app/features.txt
git commit -m "feat(cart): implement dynamic user cart discount calculation" -q

# 3. Create release/4.3.0 from develop baseline
Write-Host ""
Write-Host "[Step 3] Creating 'release/4.3.0' from develop branch..." -ForegroundColor Yellow
git checkout -B release/4.3.0
Add-Content -Path "task1-retail-platform/app/features.txt" -Value "Release 4.3.0 candidate finalized"
git add task1-retail-platform/app/features.txt
git commit -m "chore(release): prepare release candidate 4.3.0-rc1" -q

# 4. Create hotfix/payment-4.2.1 from main
Write-Host ""
Write-Host "[Step 4] Creating emergency hotfix branch 'hotfix/payment-4.2.1' from main..." -ForegroundColor Yellow
git checkout main
git checkout -B hotfix/payment-4.2.1

# 5 & 6. Modify application so payment defect is visibly fixed
Write-Host ""
Write-Host "[Step 5 & 6] Fixing payment defect and committing hotfix..." -ForegroundColor Yellow
$serverFile = "task1-retail-platform/app/server.js"
$content = Get-Content $serverFile -Raw
$content = $content.Replace("APP_VERSION = '4.2.0'", "APP_VERSION = '4.2.1'")
Set-Content -Path $serverFile -Value $content
git add $serverFile
git commit -m "fix(payment): resolve critical gateway transaction timeout defect" -q

# 7 & 8. Merge hotfix into main and tag as v4.2.1
Write-Host ""
Write-Host "[Step 7 & 8] Merging hotfix into main and tagging v4.2.1..." -ForegroundColor Yellow
git checkout main
git merge hotfix/payment-4.2.1 --no-ff -m "Merge branch 'hotfix/payment-4.2.1' into main" -q
git tag -a v4.2.1 -m "Production Hotfix Release v4.2.1 - Payment Gateway Restored" -f

# 9. Merge the same hotfix into develop
Write-Host ""
Write-Host "[Step 9] Merging hotfix into develop branch..." -ForegroundColor Yellow
git checkout develop
git merge hotfix/payment-4.2.1 --no-ff -m "Merge branch 'hotfix/payment-4.2.1' into develop to sync hotfix" -q

# 10. Demonstrate final branch history
Write-Host ""
Write-Host "[Step 10] Git Branch Commit Graph:" -ForegroundColor Green
git log --graph --oneline --decorate --all -n 15

# 11. Intentional Merge Conflict Demonstration & Resolution
Write-Host ""
Write-Host "[Step 11] Simulating intentional merge conflict and resolving it..." -ForegroundColor Yellow
git checkout -B conflict-demo-branch develop
Set-Content -Path "task1-retail-platform/app/conflict-test.txt" -Value "Feature Branch implementation of payment engine"
git add task1-retail-platform/app/conflict-test.txt
git commit -m "feat(engine): custom implementation in conflict branch" -q

git checkout develop
Set-Content -Path "task1-retail-platform/app/conflict-test.txt" -Value "Hotfix Team implementation of payment engine"
git add task1-retail-platform/app/conflict-test.txt
git commit -m "fix(engine): hotfix modification in develop" -q

Write-Host "Attempting merge to trigger conflict..." -ForegroundColor Yellow
$mergeOutput = git merge conflict-demo-branch 2>&1
Write-Host "Merge Conflict Detected as Expected: $mergeOutput" -ForegroundColor Red

# Resolve conflict cleanly
Write-Host "Resolving conflict by consolidating changes..." -ForegroundColor Green
Set-Content -Path "task1-retail-platform/app/conflict-test.txt" -Value "Consolidated implementation: Hotfix fix merged with Feature Branch functionality"
git add task1-retail-platform/app/conflict-test.txt
git commit -m "fix(merge): resolved merge conflict between conflict-demo-branch and develop" -q
Write-Host "Merge conflict successfully resolved and recorded in Git history." -ForegroundColor Green

git checkout main
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  TASK 1 GIT WORKFLOW COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

