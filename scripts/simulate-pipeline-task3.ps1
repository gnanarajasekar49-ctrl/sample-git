# Pipeline Simulator for Task 3: Blue-Green Deployment & Zero-Downtime Traffic Switching
param(
    [string]$TargetVersion = "7.9.0",
    [string]$ConfirmProd = "YES",
    [switch]$InjectFailure
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  JENKINS PIPELINE: TASK 3 BLUE-GREEN DEPLOYMENT (12 STAGES)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Stage 1: Checkout
Write-Host ""
Write-Host "[Stage 1/12] Checkout..." -ForegroundColor Yellow
$commitSha = (git rev-parse HEAD 2>$null)
if (-not $commitSha) { $commitSha = "a71f0d38c94" }
Write-Host "Checked out Git Commit: $commitSha" -ForegroundColor Green

# Stage 2: Validate Version
Write-Host ""
Write-Host "[Stage 2/12] Validate Version..." -ForegroundColor Yellow
if ($ConfirmProd -ne "YES") {
    Write-Host "FATAL ERROR: Deployment blocked because CONFIRM_PROD != YES" -ForegroundColor Red
    exit 1
}
Write-Host "Target Version $TargetVersion validated (Immutable Tag)." -ForegroundColor Green

# Stage 3: Unit/Application Test
Write-Host ""
Write-Host "[Stage 3/12] Unit/Application Test..." -ForegroundColor Yellow
node task3-orders-blue-green/tests/orders.test.js
if ($LASTEXITCODE -ne 0) { exit 1 }

# Stage 4: Docker Build
Write-Host ""
Write-Host "[Stage 4/12] Docker Build..." -ForegroundColor Yellow
Write-Host "Building Docker image orders-api:$TargetVersion with non-root user..."
Start-Sleep -Milliseconds 400
Write-Host "Image orders-api:$TargetVersion built successfully." -ForegroundColor Green

# Stage 5: Docker Image Validation
Write-Host ""
Write-Host "[Stage 5/12] Docker Image Validation..." -ForegroundColor Yellow
Write-Host "Validated metadata, entrypoint and healthcheck on orders-api:$TargetVersion." -ForegroundColor Green

# Stage 6: Start Candidate (Green Slot)
Write-Host ""
Write-Host "[Stage 6/12] Start Candidate..." -ForegroundColor Yellow
Write-Host "Current Active Slot: BLUE (orders-blue on Port 8081, Version 7.8.0)" -ForegroundColor Cyan
Write-Host "Candidate Slot:      GREEN (orders-green on Port 8082, Version $TargetVersion)" -ForegroundColor Cyan
Write-Host "Starting candidate container 'orders-green' on orders-network..."
Start-Sleep -Milliseconds 400

# Stage 7: Container Validation
Write-Host ""
Write-Host "[Stage 7/12] Container Validation..." -ForegroundColor Yellow
Write-Host "Candidate container 'orders-green' is RUNNING." -ForegroundColor Green

# Stage 8: Application Health Check
Write-Host ""
Write-Host "[Stage 8/12] Application Health Check..." -ForegroundColor Yellow
Write-Host "Probing candidate health on http://localhost:8082/health..."

if (-not $InjectFailure) {
    Write-Host "[Attempt 1/6] Health check PASSED (HTTP 200 OK: Slot GREEN is HEALTHY)." -ForegroundColor Green
    
    # Stage 9: Integration Check
    Write-Host ""
    Write-Host "[Stage 9/12] Integration Check..." -ForegroundColor Yellow
    Write-Host "Database reachability to orders-db verified from orders-green." -ForegroundColor Green
    
    # Stage 10: Traffic Switch
    Write-Host ""
    Write-Host "[Stage 10/12] Traffic Switch..." -ForegroundColor Yellow
    Write-Host "Updating Nginx upstream 'orders_backend' -> orders-green:8082..."
    Write-Host "Executing hot reload 'nginx -s reload' (Zero-Downtime)..."
    Start-Sleep -Milliseconds 300
    Write-Host "Production traffic on port 8080 now routed to GREEN (v$TargetVersion)." -ForegroundColor Green
    
    # Stage 11: Old Version Cleanup
    Write-Host ""
    Write-Host "[Stage 11/12] Old Version Cleanup..." -ForegroundColor Yellow
    Write-Host "Gracefully stopping previous slot 'orders-blue'..."
    Write-Host "Old version orders-blue stopped." -ForegroundColor Green
    
    # Stage 12: Deployment Verification
    Write-Host ""
    Write-Host "[Stage 12/12] Deployment Verification..." -ForegroundColor Yellow
    Write-Host "Testing production public proxy on http://localhost:8080/version..."
    Write-Host "Response: { service: 'orders-api', slot: 'GREEN', version: '$TargetVersion', commit: '$commitSha' }" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  BLUE-GREEN DEPLOYMENT COMPLETED WITH ZERO DOWNTIME" -ForegroundColor Green
    Write-Host "  Active Slot:    GREEN" -ForegroundColor Green
    Write-Host "  Active Version: $TargetVersion" -ForegroundColor Green
    Write-Host "  Traffic Port:   8080 (Proxy -> orders-green:8082)" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "[Attempt 1/6] Health check FAILED: HTTP 500 Internal Server Error!" -ForegroundColor Red
    Write-Host "[Attempt 2/6] Health check FAILED: Dependency timeout!" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "**********************************************************" -ForegroundColor Magenta
    Write-Host "  CANDIDATE HEALTH VALIDATION FAILED!" -ForegroundColor Magenta
    Write-Host "  ABORTING CANDIDATE & PRESERVING ACTIVE BLUE TRAFFIC" -ForegroundColor Magenta
    Write-Host "**********************************************************" -ForegroundColor Magenta
    
    Start-Sleep -Milliseconds 400
    Write-Host "1. Terminating failed candidate container 'orders-green'..."
    Write-Host "2. Verifying existing production container 'orders-blue' remains active on port 8081..."
    Write-Host "3. Confirming Nginx proxy continues serving 100% traffic from BLUE without dropped packets..."
    Write-Host "Production traffic remains 100% AVAILABLE on BLUE (v7.8.0)." -ForegroundColor Green
    
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host "  CANDIDATE ABORTED - PRODUCTION SAFEGUARDED" -ForegroundColor Red
    Write-Host "  Attempted Version: $TargetVersion (FAILED)" -ForegroundColor Red
    Write-Host "  Active Version:    7.8.0 (BLUE - ACTIVE)" -ForegroundColor Red
    Write-Host "  Final Result:      DEPLOYMENT FAILED (Candidate Dropped)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 2
}

