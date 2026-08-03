# Scenario 23: Solution

## Solution

### 1. Check current deployment strategy

```bash
kubectl describe deployment rolling-app | grep -A 10 "Strategy"

# Or via YAML
kubectl get deployment rolling-app -o yaml | grep -A 5 "strategy:"
```

Default output:
```
StrategyType:           RollingUpdate
RollingUpdate:
  Max Surge:        25%
  Max Unavailable:  25%
```

### 2. Configure custom rolling strategy

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
EOF
```

### 3. Perform rolling update

```bash
# Update image
kubectl set image deployment/rolling-app nginx=nginx:1.25

# Watch rollout status
kubectl rollout status deployment/rolling-app

# Watch pods change
kubectl get pods -l app=rolling-app -w

# In another terminal, observe:
# - New pods created (up to maxSurge limit)
# - Old pods terminated (up to maxUnavailable limit)
# - With 6 replicas, 25% = 1.5 → rounds to 2
# - So: max 8 total pods (6 + 2 surge), min 4 available (6 - 2 unavailable)
```

### 4. Verify update completed

```bash
# Check rollout history
kubectl rollout history deployment/rolling-app

# Check current pods
kubectl get pods -l app=rolling-app

# Verify new image
kubectl get pods -l app=rolling-app -o jsonpath='{.items[*].spec.containers[0].image}'
# Should show nginx:1.25

# Check all pods ready
kubectl get deployment rolling-app
```

---

## Key Concepts

**RollingUpdate Strategy:**
- **maxSurge**: Pods created above replica count during update
- **maxUnavailable**: Pods allowed to be down during update
- Can be percentages or absolute numbers

**Example with 6 replicas, maxSurge=25%, maxUnavailable=25%:**
- Max surge: 6 × 0.25 = 1.5 → rounds up to 2
- Max unavailable: 6 × 0.25 = 1.5 → rounds down to 1
- During update: Can have 6 to 8 pods total, 5 to 6 available

**Rollout process:**
1. New pods created (up to maxSurge)
2. Old pods terminated (up to maxUnavailable)
3. Repeated until all replaced

**Other strategy types:**
- **Recreate**: Kill all old pods, then start new ones (downtime)
- **RollingUpdate** (default): Zero-downtime updates

---

## Configuring Updates

**Percentage vs Absolute:**
```yaml
# Percentage
maxSurge: 25%
maxUnavailable: 25%

# Absolute numbers
maxSurge: 2
maxUnavailable: 1
```

**Conservative (slower, safe):**
```yaml
maxSurge: 1
maxUnavailable: 0
```

**Aggressive (faster, riskier):**
```yaml
maxSurge: 50%
maxUnavailable: 50%
```

---

## Exam Tips

**Update deployment image:**
```bash
kubectl set image deployment/<name> <container>=<image>
```

**Check rollout status:**
```bash
kubectl rollout status deployment/<name>
```

**Common task:** "Configure deployment to update with no downtime"
- Ensure RollingUpdate strategy set
- Set reasonable maxSurge/maxUnavailable

**Rollback if needed:**
```bash
kubectl rollout undo deployment/<name>
```
