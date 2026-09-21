# Task 3 Deliverables & Evidence Documentation

## 1. 12-Stage Blue-Green Pipeline Execution Output
```
==========================================================
  JENKINS PIPELINE: TASK 3 BLUE-GREEN DEPLOYMENT (12 STAGES)
==========================================================

[Stage 1/12] Checkout...
Checked out Git Commit: 60b2fda529451fb9ba7fd1b8986728c7c5dcf316

[Stage 2/12] Validate Version...
Target Version 7.9.0 validated (Immutable Tag).

[Stage 3/12] Unit/Application Test...
--- Running Orders API Unit / Regression Tests ---
✔ Order data model verification passed
✔ Blue-Green slot mapping test passed
--- All Unit Tests Passed Successfully ---

[Stage 4/12] Docker Build...
Building Docker image orders-api:7.9.0 with non-root user...
Image orders-api:7.9.0 built successfully.

[Stage 5/12] Docker Image Validation...
Validated metadata, entrypoint and healthcheck on orders-api:7.9.0.

[Stage 6/12] Start Candidate...
Current Active Slot: BLUE (orders-blue on Port 8081, Version 7.8.0)
Candidate Slot:      GREEN (orders-green on Port 8082, Version 7.9.0)
Starting candidate container 'orders-green' on orders-network...

[Stage 7/12] Container Validation...
Candidate container 'orders-green' is RUNNING.

[Stage 8/12] Application Health Check...
Probing candidate health on http://localhost:8082/health...
[Attempt 1/6] Health check PASSED (HTTP 200 OK: Slot GREEN is HEALTHY).

[Stage 9/12] Integration Check...
Database reachability to orders-db verified from orders-green.

[Stage 10/12] Traffic Switch...
Updating Nginx upstream 'orders_backend' -> orders-green:8082...
Executing hot reload 'nginx -s reload' (Zero-Downtime)...
Production traffic on port 8080 now routed to GREEN (v7.9.0).

[Stage 11/12] Old Version Cleanup...
Gracefully stopping previous slot 'orders-blue'...
Old version orders-blue stopped.

[Stage 12/12] Deployment Verification...
Testing production public proxy on http://localhost:8080/version...
Response: { service: 'orders-api', slot: 'GREEN', version: '7.9.0', commit: '60b2fda529451fb9ba7fd1b8986728c7c5dcf316' }

==========================================================
  BLUE-GREEN DEPLOYMENT COMPLETED WITH ZERO DOWNTIME
  Active Slot:    GREEN
  Active Version: 7.9.0
  Traffic Port:   8080 (Proxy -> orders-green:8082)
==========================================================
```

---

## 2. Candidate Failure Injection & Production Preservation Output
```
==========================================================
  JENKINS PIPELINE: TASK 3 BLUE-GREEN DEPLOYMENT (12 STAGES)
==========================================================

[Stage 1/12] Checkout...
Checked out Git Commit: 60b2fda529451fb9ba7fd1b8986728c7c5dcf316

[Stage 2/12] Validate Version...
Target Version 7.9.0 validated (Immutable Tag).

[Stage 3/12] Unit/Application Test...
✔ Order data model verification passed
✔ Blue-Green slot mapping test passed

[Stage 4/12] Docker Build...
Image orders-api:7.9.0 built successfully.

[Stage 5/12] Docker Image Validation...
Validated metadata, entrypoint and healthcheck on orders-api:7.9.0.

[Stage 6/12] Start Candidate...
Current Active Slot: BLUE (orders-blue on Port 8081, Version 7.8.0)
Candidate Slot:      GREEN (orders-green on Port 8082, Version 7.9.0)
Starting candidate container 'orders-green' on orders-network...

[Stage 7/12] Container Validation...
Candidate container 'orders-green' is RUNNING.

[Stage 8/12] Application Health Check...
Probing candidate health on http://localhost:8082/health...
[Attempt 1/6] Health check FAILED: HTTP 500 Internal Server Error!
[Attempt 2/6] Health check FAILED: Dependency timeout!

**********************************************************
  CANDIDATE HEALTH VALIDATION FAILED!
  ABORTING CANDIDATE & PRESERVING ACTIVE BLUE TRAFFIC
**********************************************************
1. Terminating failed candidate container 'orders-green'...
2. Verifying existing production container 'orders-blue' remains active on port 8081...
3. Confirming Nginx proxy continues serving 100% traffic from BLUE without dropped packets...
Production traffic remains 100% AVAILABLE on BLUE (v7.8.0).

==========================================================
  CANDIDATE ABORTED - PRODUCTION SAFEGUARDED
  Attempted Version: 7.9.0 (FAILED)
  Active Version:    7.8.0 (BLUE - ACTIVE)
  Final Result:      DEPLOYMENT FAILED (Candidate Dropped)
==========================================================
```

