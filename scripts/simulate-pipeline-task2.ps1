# Pipeline Simulator for Task 2: Multi-Environment CI/CD with Docker Network & Storage Isolation
param(
    [string]$Environment = "PRODUCTION",
    [string]$Action = "DEPLOY",
    [string]$Version = "5.0.0",
    [string]$RunTests = "YES",
    [string]$ConfirmProd = "YES"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  JENKINS PIPELINE: TASK 2 MULTI-ENVIRONMENT CI/CD" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Stage 1: Resolve Environment Matrix
Write-Host ""
Write-Host "[Stage 1/4] Resolving Deployment Target & Security Checks..." -ForegroundColor Yellow
if ($Environment -eq "PRODUCTION" -and $ConfirmProd -ne "YES") {
    Write-Host "FATAL ERROR: Production deployment BLOCKED because CONFIRM_PROD != YES!" -ForegroundColor Red
    exit 1
}

$branch = ""
$port = ""
$app = ""
$db = ""
$net = ""
$vol = ""

switch ($Environment) {
    "DEV" {
        $branch = "develop"
        $port = "8081"
        $app = "customer-app-dev"
        $db = "customer-db-dev"
        $net = "customer-dev-net"
        $vol = "customer-db-dev-data"
    }
    "UAT" {
        $branch = "release"
        $port = "8082"
        $app = "customer-app-uat"
        $db = "customer-db-uat"
        $net = "customer-uat-net"
        $vol = "customer-db-uat-data"
    }
    "PRODUCTION" {
        $branch = "main"
        $port = "8083"
        $app = "customer-app-prod"
        $db = "customer-db-prod"
        $net = "customer-prod-net"
        $vol = "customer-db-prod-data"
    }
}

Write-Host "Resolved Target Environment Matrix:"
Write-Host "  Environment:       $Environment"
Write-Host "  Git Branch:        $branch"
Write-Host "  Application Name:  $app"
Write-Host "  Database Name:     $db"
Write-Host "  Host Port:         $port"
Write-Host "  Docker Network:    $net"
Write-Host "  Storage Volume:    $vol"
Write-Host "  Target Version:    $Version"
Write-Host "Resolved deployment configuration printed." -ForegroundColor Green

# Stage 2: Automated Tests
Write-Host ""
Write-Host "[Stage 2/4] Running Environment Tests..." -ForegroundColor Yellow
if ($RunTests -eq "YES") {
    node task2-customer-service/tests/customer.test.js
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

# Stage 3: Deploy Stack
Write-Host ""
Write-Host "[Stage 3/4] Deploying Isolated Docker Stack (App + DB)..." -ForegroundColor Yellow
Write-Host "  -> Creating custom bridge network: $net"
Write-Host "  -> Attaching named persistent volume: $vol"
Write-Host "  -> Launching database container '$db' (internal port 5432 only)"
Write-Host "  -> Launching application container '$app' on port $port"
Start-Sleep -Milliseconds 400

# Stage 4: 8-Point Deployment Validation
Write-Host ""
Write-Host "[Stage 4/4] Executing Mandatory 8-Point Deployment Validation..." -ForegroundColor Yellow

$dbConnected = $true
if ($Version -eq "5.1.0-fail") {
    $dbConnected = $false
}

Write-Host "  [Check 18] Verifying Docker image customer-app:$Version exists... PASSED" -ForegroundColor Green
Write-Host "  [Check 19] Verifying application container '$app' is running... PASSED" -ForegroundColor Green
Write-Host "  [Check 20] Verifying database container '$db' is running... PASSED" -ForegroundColor Green
Write-Host "  [Check 21] Verifying containers are attached to network '$net'... PASSED" -ForegroundColor Green

if ($dbConnected) {
    Write-Host "  [Check 22] Probing application health endpoint (http://localhost:$port/health)... PASSED (HTTP 200)" -ForegroundColor Green
    Write-Host "  [Check 23] Testing app-to-database communication (http://localhost:$port/api/db-status)... PASSED (Connected to ${db}:5432)" -ForegroundColor Green
    Write-Host "  [Check 24] Validating displayed environment ('$Environment')... PASSED" -ForegroundColor Green
    Write-Host "  [Check 25] Validating deployed version ('$Version')... PASSED" -ForegroundColor Green

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  TASK 2 MULTI-ENVIRONMENT DEPLOYMENT SUCCESSFUL" -ForegroundColor Green
    Write-Host "  Environment: $Environment | App: $app | Version: $Version" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "  [Check 22] Probing application health endpoint (http://localhost:$port/health)... FAILED (HTTP 500)" -ForegroundColor Red
    Write-Host "  [Check 23] Testing app-to-database communication... FAILED: Connection refused to $db" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "**********************************************************" -ForegroundColor Magenta
    Write-Host "  DEPLOYMENT VALIDATION FAILED: DATABASE UNREACHABLE" -ForegroundColor Magenta
    Write-Host "  TRIGGERING AUTOMATIC ROLLBACK TO KNOWN GOOD VERSION 5.0.0" -ForegroundColor Magenta
    Write-Host "**********************************************************" -ForegroundColor Magenta
    
    Start-Sleep -Milliseconds 400
    Write-Host "1. Redeploying stable application container customer-app:5.0.0..."
    Write-Host "2. Running validation checks on restored 5.0.0 container..."
    Write-Host "Restored container customer-app-prod (5.0.0) verified healthy and connected to $db." -ForegroundColor Green
    
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host "  TASK 2 AUTOMATED ROLLBACK COMPLETED" -ForegroundColor Red
    Write-Host "  Candidate Version: 5.1.0-fail (FAILED)" -ForegroundColor Red
    Write-Host "  Restored Version:  5.0.0 (ACTIVE)" -ForegroundColor Red
    Write-Host "  Final Result:      ROLLBACK (Jenkins Build FAILED)" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    exit 2
}

