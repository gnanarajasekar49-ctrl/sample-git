# Production Incident Post-Mortem & Investigation (INC-84920)

## Incident Overview
- **Application:** `orders-api`
- **Reported Impact:** Users unable to access Orders API (`502 Bad Gateway` / `Connection Refused`) following Jenkins deployment.
- **Reported Version:** Candidate release `v7.9.0`
- **Initial Status:** Jenkins build showed **SUCCESS**, yet production traffic was completely disrupted.

---

## Phase 1: 10-Step Structured Incident Investigation

### 1. Check Git Commit and Branch Used by Jenkins
- **Investigation:** Examined Jenkins workspace git log.
- **Finding:** Jenkins pulled commit `e8f49b1` on branch `feature/speed-optimizations` instead of the approved `main` branch.

### 2. Check Jenkins Console Output
- **Investigation:** Inspected step-by-step console logs.
- **Finding:** The deployment script executed `docker run -d -p 8080:8080 orders-api:7.9.0`, but lacked an application health check stage. The step succeeded merely because the container creation command exited with return code `0`.

### 3. Check Docker Container Status
- **Investigation:** Ran `docker ps -a --filter name=orders`
- **Finding:** Container `orders-green` had status `Restarting (1) 12 seconds ago` (CrashLoopBackOff).

### 4. Check Container Logs
- **Investigation:** Ran `docker logs orders-green`
- **Finding:** `Error: connect ECONNREFUSED 127.0.0.1:5432`. The application attempted to connect to `localhost:5432` instead of the database container DNS hostname `orders-db`.

### 5. Inspect Container Environment Variables
- **Investigation:** Ran `docker inspect --format '{{json .Config.Env}}' orders-green`
- **Finding:** `DB_HOST` was unassigned; defaulted to `localhost` inside the container isolation boundary.

### 6. Inspect Container Port Mappings
- **Investigation:** Ran `docker port orders-green`
- **Finding:** Host port `8080` was bound to container port `8080`, but the application process inside was configured to listen on port `8081`.

### 7. Inspect Docker Network
- **Investigation:** Ran `docker network inspect orders-network`
- **Finding:** `orders-db` was on `orders-network`, but `orders-green` was mistakenly launched on the default `bridge` network. Inter-container DNS name resolution failed.

### 8. Test Application From Inside and Outside Container
- **Investigation:** Ran `curl http://localhost:8080` (Failed: `Empty reply from server`). Ran `docker exec orders-green curl http://localhost:8081/health` (Failed: connection refused as app crashed on missing DB).

### 9. Check Application Process Listening State
- **Investigation:** Ran `netstat -tlpn` inside container.
- **Finding:** No process listening due to unhandled promise rejection during DB initialization.

### 10. Identify Root Cause & Action Items
- **Root Cause Summary:**
  1. Pipeline lacked pre-traffic validation and health checks.
  2. The old Blue container was aggressively killed before validating the Green container.
  3. Misconfigured environment variable (`DB_HOST`) and network attachment.
- **Resolution:**
  1. Immediately redeployed known-good image `orders-api:7.8.0` on `orders-blue` (`orders-network`).
  2. Implemented automated Blue-Green traffic routing via Nginx proxy with zero-downtime healthcheck gates.

---

## Phase 6: Recovery Flow Architecture

```
Current Production (BLUE: v7.8.0)
       |
       v
Candidate Deployment (GREEN: v7.9.0)
       |
       v
Application Health & DB Validation
       |
       +-----------------------+
       |                       |
     [PASS]                  [FAIL]
       |                       |
       v                       v
 Switch Traffic to GREEN    Remove Failed Candidate (GREEN)
       |                       |
       v                       v
 Decommission BLUE          Keep Current BLUE Production (v7.8.0)
```

