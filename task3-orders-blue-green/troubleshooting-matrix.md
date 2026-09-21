# Comprehensive DevOps Troubleshooting Matrix (Scenarios 26–37)

This reference document details the root causes, diagnostic commands, and remediation strategies for all 12 common enterprise failure scenarios.

---

| # | Failure Scenario | Symptom / Indicators | Diagnostic Commands | Root Cause & Remediation |
|---|---|---|---|---|
| **26** | **Candidate starts but immediately exits** | Container status `Exited (1)` immediately after launch. | `docker ps -a`, `docker logs <container_name>` | **Cause:** Entrypoint syntax error, missing file, or unhandled startup exception.<br>**Fix:** Fix CMD/ENTRYPOINT in Dockerfile, check process logs. |
| **27** | **Candidate running but health endpoint fails** | Container is `Up`, but `curl http://localhost:PORT/health` returns HTTP 500 or timeout. | `docker logs <container>`, `curl -v http://localhost:PORT/health` | **Cause:** Internal dependency deadlocked, uninitialized cache, or health check route exception.<br>**Fix:** Inspect stack trace, repair health check handler. |
| **28** | **Candidate uses wrong application port** | Port mismatch; connection refused when curling host port. | `docker port <container>`, `netstat -tlpn` inside container | **Cause:** App listening on e.g. 3000 but Dockerfile/Compose mapped 8081.<br>**Fix:** Align `PORT` environment variable and `EXPOSE` directives. |
| **29** | **Candidate cannot reach database** | DB timeout or ECONNREFUSED in application logs. | `docker exec <app_container> nc -zv <db_host> 5432` | **Cause:** DB service down or container DNS unresolved.<br>**Fix:** Check DB container status and network connectivity. |
| **30** | **Database hostname is incorrect** | DNS resolution failure `getaddrinfo ENOTFOUND`. | `docker exec <app_container> ping <db_host>`, `env` | **Cause:** App configured with `localhost` or typo in `DB_HOST`.<br>**Fix:** Update environment variable to match database container name. |
| **31** | **Required environment variable is absent** | App crashes with `Undefined Variable` / `Missing Configuration`. | `docker inspect --format '{{json .Config.Env}}' <container>` | **Cause:** Missing secret or omitted env file in docker run/compose.<br>**Fix:** Inject variable via Jenkins parameters / compose environment. |
| **32** | **Docker network is incorrect** | Containers cannot communicate even with correct names. | `docker network inspect <network_name>` | **Cause:** App and DB attached to separate Docker networks.<br>**Fix:** Attach both containers to the shared custom bridge network. |
| **33** | **Previous container has occupied host port** | `Error response from daemon: Bind for 0.0.0.0:8081 failed: port is already allocated`. | `docker ps --filter publish=8081`, `netstat -ano \| findstr 8081` | **Cause:** Orphaned container or lingering process on host port.<br>**Fix:** Stop/remove dangling container before candidate bind. |
| **34** | **Jenkins has incorrect Git credentials** | Git checkout fails with `Authentication Failed` / `Permission Denied`. | Jenkins console log in `Checkout` stage. | **Fix:** Update credentials ID in Jenkins pipeline or refresh SSH key/token. |
| **35** | **Jenkins builds wrong branch** | Deployed application does not reflect latest feature commit. | `git rev-parse HEAD`, Jenkins build parameters. | **Fix:** Use dynamic branch specifier `${TARGET_BRANCH}` mapped from environment. |
| **36** | **Docker image exists but requested version tag does not** | `Error: manifest for app:version not found`. | `docker images`, `git tag -l` | **Fix:** Ensure build stage creates exact semver tag matching `${VERSION}`. |
| **37** | **Application returns HTTP 500 after deployment** | Endpoint crashes under runtime request load. | `docker logs -f <container>`, application APM logs. | **Fix:** Inspect runtime exceptions, handle edge cases, rollback to previous image. |

