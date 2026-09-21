# Pipeline Simulator for Task 1: Retail Platform Release & Rollback
param(
    [string]$Action = "DEPLOY",
    [string]$Environment = "PRODUCTION",
    [string]$Version = "4.2.1",
    [string]$ConfirmProd = "YES"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  JENKINS PIPELINE: TASK 1 ENTERPRISE RELEASE & ROLLBACK" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[PARAMETER] DEPLOYMENT_ACTION = $Action"
Write-Host "[PARAMETER] ENVIRONMENT       = $Environment"
Write-Host "[PARAMETER] VERSION           = $Version"
Write-Host "[PARAMETER] CONFIRM_PROD      = $ConfirmProd"
Write-Host "----------------------------------------------------------"

# Stage 1: Safety & Parameter Validation
Write-Host ""
Write-Host "[Stage 1/6] Safety & Parameter Validation..." -ForegroundColor Yellow
if ($Environment -eq "PRODUCTION" -and $ConfirmProd -ne "YES") {
    Write-Host "FATAL ERROR: Production deployment BLOCKED because CONFIRM_PROD != YES!" -ForegroundColor Red
    exit 1
}
Write-Host "Safety check verified: Production deployment confirmed." -ForegroundColor Green

# Stage 2: Checkout & Version Traceability
Write-Host ""
Write-Host "[Stage 2/6] Checkout & Version Traceability..." -ForegroundColor Yellow
$commitSha = (git rev-parse HEAD 2>$null)
if (-not $commitSha) { $commitSha = "c8f3a9e210b4" }
Write-Host "Active Git Commit SHA: $commitSha" -ForegroundColor Green
Write-Host "Validated semantic version tag: v$Version" -ForegroundColor Green

# Stage 3: Run Unit & Regression Tests
Write-Host ""
Write-Host "[Stage 3/6] Running Unit & Regression Tests..." -ForegroundColor Yellow
node task1-retail-platform/tests/app.test.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "FATAL ERROR: Unit tests failed!" -ForegroundColor Red
    exit 1
}

# Stage 4: Record Previous Production State
Write-Host ""
Write-Host "[Stage 4/6] Recording Previous Active Image..." -ForegroundColor Yellow
$previousImage = "retail-app:4.2.0"
Write-Host "Previous Active Production Image Recorded: $previousImage" -ForegroundColor Green

# Stage 5: Docker Build & Package
Write-Host ""
Write-Host "[Stage 5/6] Docker Build & Packaging Image (retail-app:$Version)..." -ForegroundColor Yellow
Write-Host "Building Docker Image: retail-app:$Version using Dockerfile (Non-Root User: node)..."
Start-Sleep -Milliseconds 500
Write-Host "Docker image retail-app:$Version built successfully with HEALTHCHECK directive." -ForegroundColor Green

# Stage 6: Candidate Deployment & Health Validation
Write-Host ""
Write-Host "[Stage 6/6] Deploying Candidate Container alongside Production..." -ForegroundColor Yellow
$targetImage = "retail-app:$Version"
$candidatePort = "8089"

Write-Host "Starting Candidate container 'retail-app-candidate' on port $candidatePort..."
Start-Sleep -Milliseconds 400

# Perform Health Check
Write-Host "Probing candidate health on http://localhost:$candidatePort/health..."
$isHealthy = $true
if ($Version -eq "4.2.2") {
    $isHealthy = $false
}

if ($isHealthy) {
    Write-Host "[Attempt 1/6] Health check HTTP 200 OK received! Status: UP" -ForegroundColor Green
    Write-Host "Health check PASSED! Promoting candidate container to active production port 8081..."
    Start-Sleep -Milliseconds 400
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  DEPLOYMENT SUCCESSFUL" -ForegroundColor Green
    Write-Host "  Previous Version: $previousImage" -ForegroundColor Green
    Write-Host "  Deployed Version: $targetImage" -ForegroundColor Green
    Write-Host "  Final State:      ACTIVE ON PORT 8081" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "[Attempt 1/6] Health check returned HTTP 500: simulated payment gateway failure!" -ForegroundColor Red
    Write-Host "[Attempt 2/6] Health check returned HTTP 500: simulated payment gateway failure!" -ForegroundColor Red
    Write-Host "[Attempt 3/6] Health check TIMEOUT: Candidate unhealthy after 3 retries!" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "**********************************************************" -ForegroundColor Magenta
    Write-Host "  CRITICAL: CANDIDATE HEALTH CHECK FAILED!" -ForegroundColor Magenta
    Write-Host "  INITIATING AUTOMATIC ROLLBACK TO PREVIOUS: $previousImage" -ForegroundColor Magenta
    Write-Host "**********************************************************" -ForegroundColor Magenta
    
    Start-Sleep -Milliseconds 500
    Write-Host "1. Stopping and removing failed candidate container 'retail-app-candidate'..."
    Write-Host "2. Verifying existing production container ($previousImage) remains active on port 8081..."
    Write-Host "3. Executing healthcheck on restored production container http://localhost:8081/health..."
    Write-Host "Restored production container verified HEALTHY (HTTP 200 OK)." -ForegroundColor Green
    
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host "  AUTOMATED ROLLBACK VERIFIED & COMPLETED" -ForegroundColor Red
    Write-Host "  Attempted Version: $targetImage (FAILED - ROLLED BACK)" -ForegroundColor Red
    Write-Host "  Restored Version:  $previousImage (ACTIVE)" -ForegroundColor Red
    Write-Host "  Final State:       RESTORED TO SAFE BASELINE" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "Jenkins Final Status: FAILURE (Rollback was required)" -ForegroundColor Red
    exit 2
}

