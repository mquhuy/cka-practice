# Scenario 16: Probes (Liveness, Readiness, Startup)

**Time:** 6 minutes | **Difficulty:** Medium

---

## Tasks

### 1. Create pod with liveness probe
Create pod `probe-pod` with nginx:
- **Liveness probe**: HTTP GET on `/` port 80, initial delay 5s, period 5s
- If probe fails, pod restarts

### 2. Add readiness probe
Add readiness probe:
- HTTP GET on `/` port 80
- Pod not ready until probe passes
- Initial delay 3s

### 3. Test probe behavior
- Verify pod becomes Ready after initial delay
- Check probe configuration

### 4. Create failing probe pod
Create pod `fail-pod` with intentional liveness failure:
- Runs `busybox` with command `sleep 30; exit 1`
- TCP probe on port 8080 (which doesn't exist)
- Observe restart behavior

---

## Hints

<details>
<summary>Probe YAML structure</summary>

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 3
```
</details>

<details>
<summary>Probe types</summary>

- `httpGet`: HTTP endpoint check
- `tcpSocket`: TCP port check
- `exec`: Command execution check
</details>

---

## Verification

```bash
# Check pod status (shows restart count)
kubectl get pod probe-pod

# Check probe details
kubectl describe pod probe-pod | grep -A 10 "Liveness\|Readiness"

# Watch restarts
kubectl get pod fail-pod -w
```
