# Scenario 16: Solution

## Solution

### 1. Create pod with liveness probe

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
spec:
  containers:
  - name: nginx
    image: nginx
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
EOF
```

### 2. Add readiness probe

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
spec:
  containers:
  - name: nginx
    image: nginx
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
EOF
```

### 3. Test probe behavior

```bash
# Pod shows Ready: 1/1 after ~3 seconds
kubectl get pod probe-pod

# Check probe configuration
kubectl describe pod probe-pod | grep -A 15 "Liveness\|Readiness"

# Check events for probe results
kubectl describe pod probe-pod | grep -A 5 Events
```

### 4. Create failing probe pod

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: fail-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

# Watch it restart
kubectl get pod fail-pod -w

# After 10s you'll see RESTARTS increment
```

---

## Key Concepts

**Probe Types:**
- **Liveness**: Container restarts on failure. Fix stuck apps.
- **Readiness**: Pod removed from Service on failure. Handle startup/overload.
- **Startup**: For slow-start containers. Disables liveness/readiness until it succeeds.

**Probe Handlers:**
- `httpGet`: HTTP endpoint (most common)
- `tcpSocket`: TCP port open check
- `exec`: Command exit code (0 = success)

**Common Parameters:**
- `initialDelaySeconds`: Wait before first probe
- `periodSeconds`: How often to probe
- `timeoutSeconds`: Probe timeout
- `successThreshold`: Consecutive successes to mark healthy
- `failureThreshold`: Consecutive failures before action

**Default Values:**
- `initialDelaySeconds: 0`
- `periodSeconds: 10`
- `timeoutSeconds: 1`
- `successThreshold: 1`
- `failureThreshold: 3`

---

## Exam Tips

**Common scenario:** App not ready, fails service calls → Add readiness probe.

**Check why pod not Ready:**
```bash
kubectl describe pod <name> | grep -A 5 "Readiness"
```

**Probe fails = restart count increases** (for liveness)
