# Scenario 17: Solution

## Solution

### 1. Create HPA

**Method 1: Imperative (CPU only)**
```bash
kubectl autoscale deployment test-app --min=2 --max=5 --cpu-percent=70
```

**Method 2: YAML (CPU + Memory)**
```bash
kubectl apply -f - <<EOF
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
EOF
```

### 2. Verify HPA created

```bash
# List all HPA
kubectl get hpa

# Describe HPA (shows targets, current metrics)
kubectl describe hpa test-hpa

# Check HPA YAML
kubectl get hpa test-hpa -o yaml
```

Output:
```
NAME       REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
test-hpa   Deployment/test-app   50%/70% / 30%/80%   2        5         2          1m
```

### 3. Generate load and observe scaling

```bash
# Create load generator
kubectl run load-gen --image=busybox --restart=Never -it -- \
  sh -c 'while true; do wget -O- http://test-app > /dev/null 2>&1; done'

# In another terminal, watch HPA
kubectl get hpa test-hpa -w

# Watch deployment replicas
kubectl get deployment test-app -w
```

### 4. Check HPA behavior

```bash
# Check current metrics
kubectl top pods -l app=test-app

# Check HPA conditions
kubectl describe hpa test-hpa | grep -A 10 "Conditions:"

# View events
kubectl get events --sort-by='.lastTimestamp' | grep hpa
```

---

## Key Concepts

**HPA Requirements:**
- Metrics server must be deployed
- Deployment/ReplicaSet/RC must have resource requests defined
- HPA checks metrics every 15 seconds (default)

**Scaling Behavior:**
- Scales up when metric > target
- Scales down when metric < target (with cooldown)
- Scale-down stabilization: 5 minutes default

**Metric Types:**
- `Resource`: CPU, memory (requires metrics-server)
- `Pods`: Custom metrics from pods
- `Object`: Custom metrics from objects

---

## Exam Tips

**Common task:** "Scale deployment based on CPU"

```bash
kubectl autoscale deployment <name> --min=2 --max=5 --cpu-percent=70
```

**Check why HPA not scaling:**
1. Metrics server running? `kubectl get pods -n kube-system | grep metrics`
2. Resource requests set? `kubectl describe deploy <name> | grep Requests`
3. Current metrics below target? `kubectl describe hpa <name>`

**Imperative vs YAML:**
- Imperative: CPU only, quick
- YAML: CPU + memory + custom metrics
