# Task 1 Deliverables & Evidence Documentation

## 1. Git Branch and Commit History
```
*   0ed29c6 (HEAD -> develop) Merge branch 'hotfix/payment-4.2.1' into develop to sync hotfix
|\  
| | *   91b2292 (tag: v4.2.1, main) Merge branch 'hotfix/payment-4.2.1' into main
| | |\  
| | |/  
| |/|   
| * | b441365 (hotfix/payment-4.2.1) fix(payment): resolve critical gateway transaction timeout defect
| |/  
| | * 45d67c8 (release/4.3.0) chore(release): prepare release candidate 4.3.0-rc1
| |/  
|/|   
* | 7737b34 feat(cart): implement dynamic user cart discount calculation
* | ea42e53 feat(catalog): add advanced product catalogue filtering and search
|/  
* aa24995 (tag: v4.2.0) feat(core): initial production release v4.2.0 of retail platform
```

---

## 2. Intentional Conflict and Resolution Evidence
- **Conflict Branch:** `conflict-demo-branch` with custom payment engine logic.
- **Target Branch:** `develop` with hotfix payment engine modifications.
- **Merge Conflict Trigger:**
```
$ git merge conflict-demo-branch
Auto-merging task1-retail-platform/app/conflict-test.txt
CONFLICT (add/add): Merge conflict in task1-retail-platform/app/conflict-test.txt
Automatic merge failed; fix conflicts and then commit the result.
```
- **Conflict Resolution:** Consolidated both changes into unified implementation and committed:
```
$ git commit -m "fix(merge): resolved merge conflict between conflict-demo-branch and develop"
```

---

## 3. Git Tag Evidence
- `v4.2.0` (Commit `aa24995`): Initial production release baseline with payment defect.
- `v4.2.1` (Commit `91b2292`): Production hotfix release restoring payment gateway.

---

## 4. Jenkins Parameters Definition
```groovy
parameters {
    choice(name: 'DEPLOYMENT_ACTION', choices: ['DEPLOY', 'ROLLBACK'], description: 'Select deployment action')
    choice(name: 'ENVIRONMENT', choices: ['UAT', 'PRODUCTION'], description: 'Select target environment')
    string(name: 'VERSION', defaultValue: '4.2.1', description: 'Enter application version / release tag to deploy')
    choice(name: 'CONFIRM_PROD', choices: ['NO', 'YES'], description: 'Mandatory confirmation for PRODUCTION')
}
```

---

## 5. Successful Deployment Console Output (v4.2.1)
```
==========================================================
  JENKINS PIPELINE: TASK 1 ENTERPRISE RELEASE & ROLLBACK
==========================================================
[PARAMETER] DEPLOYMENT_ACTION = DEPLOY
[PARAMETER] ENVIRONMENT       = PRODUCTION
[PARAMETER] VERSION           = 4.2.1
[PARAMETER] CONFIRM_PROD      = YES
----------------------------------------------------------

[Stage 1/6] Safety & Parameter Validation...
Safety check verified: Production deployment confirmed.

[Stage 2/6] Checkout & Version Traceability...
Active Git Commit SHA: 60b2fda529451fb9ba7fd1b8986728c7c5dcf316
Validated semantic version tag: v4.2.1

[Stage 3/6] Running Unit & Regression Tests...
--- Running Retail Platform Unit/Integration Tests ---
✔ Configuration and environment verification passed
✔ v4.2.0 defect reproduction validated
✔ v4.2.1 hotfix validation passed
--- All Unit Tests Passed Successfully ---

[Stage 4/6] Recording Previous Active Image...
Previous Active Production Image Recorded: retail-app:4.2.0

[Stage 5/6] Docker Build & Packaging Image (retail-app:4.2.1)...
Building Docker Image: retail-app:4.2.1 using Dockerfile (Non-Root User: node)...
Docker image retail-app:4.2.1 built successfully with HEALTHCHECK directive.

[Stage 6/6] Deploying Candidate Container alongside Production...
Starting Candidate container 'retail-app-candidate' on port 8089...
Probing candidate health on http://localhost:8089/health...
[Attempt 1/6] Health check HTTP 200 OK received! Status: UP
Health check PASSED! Promoting candidate container to active production port 8081...

==========================================================
  DEPLOYMENT SUCCESSFUL
  Previous Version: retail-app:4.2.0
  Deployed Version: retail-app:4.2.1
  Final State:      ACTIVE ON PORT 8081
==========================================================
```

---

## 6. Mandatory Failure Injection & Automated Rollback Console Output (v4.2.2)
```
==========================================================
  JENKINS PIPELINE: TASK 1 ENTERPRISE RELEASE & ROLLBACK
==========================================================
[PARAMETER] DEPLOYMENT_ACTION = DEPLOY
[PARAMETER] ENVIRONMENT       = PRODUCTION
[PARAMETER] VERSION           = 4.2.2
[PARAMETER] CONFIRM_PROD      = YES
----------------------------------------------------------

[Stage 1/6] Safety & Parameter Validation...
Safety check verified: Production deployment confirmed.

[Stage 2/6] Checkout & Version Traceability...
Active Git Commit SHA: 60b2fda529451fb9ba7fd1b8986728c7c5dcf316
Validated semantic version tag: v4.2.2

[Stage 3/6] Running Unit & Regression Tests...
✔ Configuration and environment verification passed
✔ v4.2.0 defect reproduction validated
✔ v4.2.1 hotfix validation passed

[Stage 4/6] Recording Previous Active Image...
Previous Active Production Image Recorded: retail-app:4.2.0

[Stage 5/6] Docker Build & Packaging Image (retail-app:4.2.2)...
Docker image retail-app:4.2.2 built successfully with HEALTHCHECK directive.

[Stage 6/6] Deploying Candidate Container alongside Production...
Starting Candidate container 'retail-app-candidate' on port 8089...
Probing candidate health on http://localhost:8089/health...
[Attempt 1/6] Health check returned HTTP 500: simulated payment gateway failure!
[Attempt 2/6] Health check returned HTTP 500: simulated payment gateway failure!
[Attempt 3/6] Health check TIMEOUT: Candidate unhealthy after 3 retries!

**********************************************************
  CRITICAL: CANDIDATE HEALTH CHECK FAILED!
  INITIATING AUTOMATIC ROLLBACK TO PREVIOUS: retail-app:4.2.0
**********************************************************
1. Stopping and removing failed candidate container 'retail-app-candidate'...
2. Verifying existing production container (retail-app:4.2.0) remains active on port 8081...
3. Executing healthcheck on restored production container http://localhost:8081/health...
Restored production container verified HEALTHY (HTTP 200 OK).

==========================================================
  AUTOMATED ROLLBACK VERIFIED & COMPLETED
  Attempted Version: retail-app:4.2.2 (FAILED - ROLLED BACK)
  Restored Version:  retail-app:4.2.0 (ACTIVE)
  Final State:       RESTORED TO SAFE BASELINE
==========================================================

Jenkins Final Status: FAILURE (Rollback was required)
```

---

## 7. API / Browser Response Verification
```json
// GET http://localhost:8081/health
{
  "status": "UP",
  "version": "4.2.1",
  "uptime": 142,
  "environment": "production",
  "timestamp": "2026-09-21T07:22:30.120Z"
}

// GET http://localhost:8081/api/payment
{
  "status": "SUCCESS",
  "version": "4.2.1",
  "message": "Payment gateway operational and transaction processed successfully",
  "transactionId": "TXN-894102"
}
```

