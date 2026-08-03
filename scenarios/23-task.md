# Scenario 23: Rolling Update Strategy

**Time:** 6 minutes | **Difficulty:** Medium

---

## Context

Deployments support rolling updates. Configure `maxSurge` and `maxUnavailable` to control update behavior.

---

## Prerequisites

```bash
kubectl create deployment rolling-app --image=nginx:1.24 --replicas=6
```

---

## Tasks

### 1. Check current deployment strategy
Examine the deployment's rolling update strategy.

### 2. Configure custom rolling strategy
Update deployment `rolling-app`:
- **maxSurge**: 25% (can create 25% more pods than desired)
- **maxUnavailable**: 25% (can have 25% unavailable during update)

### 3. Perform rolling update
Update image to `nginx:1.25`:
- Watch rolling update in progress
- Verify replicas stay within bounds

### 4. Verify update completed
Check rollout history and final state.

---

## Hints

<details>
<summary>Strategy YAML structure</summary>

```yaml
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
```
</details>

<details>
<summary>Rolling update behavior</summary>

- **maxSurge**: How many extra pods can be created during update
- **maxUnavailable**: How many pods can be down during update
- Both can be absolute numbers or percentages
- Default: 25% for both
</details>

<details>
<summary>Watch rolling update</summary>

```bash
kubectl rollout status deployment/rolling-app
kubectl get pods -l app=rolling-app -w
```
</details>

---

## Verification

```bash
# Check strategy
kubectl describe deploy rolling-app | grep -A 5 "Strategy"

# Watch update
kubectl rollout status deployment/rolling-app

# Check revision history
kubectl rollout history deployment/rolling-app

# Verify new image running
kubectl get pods -l app=rolling-app -o jsonpath='{.items[*].spec.containers[0].image}'
```
