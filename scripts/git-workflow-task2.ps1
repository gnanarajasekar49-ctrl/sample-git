# PowerShell Script: Git Workflow Automation for Task 2
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  EXECUTING GIT WORKFLOW FOR TASK 2 (MULTI-ENV STRATEGY)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

git checkout main
git add task2-customer-service/
git commit -m "feat(core): initial multi-environment customer service baseline" -q --allow-empty
git tag -a v5.0.0 -m "Production Release v5.0.0" -f

git checkout develop
git checkout -B feature/customer-search

# Commit 1: Add customer search logic
Set-Content -Path "task2-customer-service/app/search-feature.txt" -Value "Commit 1: Implement basic customer keyword filtering"
git add task2-customer-service/app/search-feature.txt
git commit -m "feat(search): add keyword search parser and index lookup" -q

# Commit 2: Add pagination and filters
Add-Content -Path "task2-customer-service/app/search-feature.txt" -Value "Commit 2: Add customer tier filter and sorting"
git add task2-customer-service/app/search-feature.txt
git commit -m "feat(search): add multi-tier customer filtering and sorting algorithms" -q

# Commit 3: Add caching & optimization
Add-Content -Path "task2-customer-service/app/search-feature.txt" -Value "Commit 3: Add in-memory query cache for high throughput"
git add task2-customer-service/app/search-feature.txt
git commit -m "perf(search): implement search query response caching" -q

# Merge feature into develop
Write-Host ""
Write-Host "Merging feature/customer-search into develop..." -ForegroundColor Yellow
git checkout develop
git merge feature/customer-search --no-ff -m "Merge branch 'feature/customer-search' into develop" -q

# Promote release into release/5.1.0 branch
Write-Host ""
Write-Host "Promoting develop into release/5.1.0 branch for UAT..." -ForegroundColor Yellow
git checkout -B release/5.1.0
git merge develop --no-ff -m "chore(release): promote develop to release/5.1.0 branch for UAT validation" -q

# Merge into main after UAT validation and tag production
Write-Host ""
Write-Host "Merging release/5.1.0 into main and tagging production release..." -ForegroundColor Yellow
git checkout main
git merge release/5.1.0 --no-ff -m "Merge branch 'release/5.1.0' into main" -q
git tag -a v5.1.0 -m "Production Release v5.1.0 - Customer Search Feature Live" -f

Write-Host ""
Write-Host "Git Graph for Task 2 Strategy:" -ForegroundColor Green
git log --graph --oneline --decorate -n 14

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  TASK 2 GIT WORKFLOW COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

