# Scenario 17: Horizontal Pod Autoscaler (HPA)

**Time:** 6 minutes | **Difficulty:** Medium

---

## Prerequisites

```bash
# Deploy metrics server first
kubectl apply -f ../manifests/metrics-server.yaml

# Create test deployment
kubectl create deployment test-app --image=nginx --replicas=2
```

---

## Tasks

### 1. Create HPA
Create HPA named `test-hpa` for `test-app` deployment:
- **Min replicas**: 2
- **Max replicas**: 5
- **Target CPU utilization**: 70%
- **Target memory utilization**: 80%

### 2. Verify HPA created
Check HPA status and current metrics.

### 3. Generate load and observe scaling
Create a load generator pod to stress the deployment:
- Watch HPA scale up replicas

### 4. Check HPA behavior
View HPA metrics and replica changes over time.

---

## Hints

<details>
<summary>HPA imperative creation</summary>

```bash
kubectl autoscale deployment test-app --min=2 --max=5 --cpu-percent=70
```
</details>

<details>
<summary>HPA YAML with memory target</summary>

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: test-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: test-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```
</details>

---

## Verification

```bash
# Check HPA status
kubectl get hpa
kubectl describe hpa test-hpa

# Check current metrics
kubectl top pods
kubectl top nodes

# Watch HPA events
kubectl get hpa test-hpa -w
```
