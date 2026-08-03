# Scenario 13: Solution

## Solution

### 1. Create pod with resources

**Method 1: Imperative (faster for exam)**
```bash
kubectl run resource-pod --image=nginx --restart=Never \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi --dry-run=client -o yaml | kubectl apply -f -
```

**Method 2: YAML**
```bash
cat > pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF
kubectl apply -f pod.yaml
```

### 2. Verify resource allocation
```bash
kubectl describe pod resource-pod | grep -A 2 "Requests\|Limits"

# Or use jsonpath:
kubectl get pod resource-pod -o jsonpath='{.spec.containers[0].resources.requests.cpu}'
kubectl get pod resource-pod -o jsonpath='{.spec.containers[0].resources.limits.cpu}'
```

### 3. Check QoS class
```bash
kubectl get pod resource-pod -o jsonpath='{.status.qosClass}'
# Output: Burstable

# Full view:
kubectl get pod resource-pod -o yaml | grep qosClass
```

### 4. Create Guaranteed QoS pod
```bash
kubectl run guaranteed-pod --image=redis --restart=Never \
  --requests=cpu=500m,memory=512Mi \
  --limits=cpu=500m,memory=512Mi --dry-run=client -o yaml | kubectl apply -f -
```

Verify QoS class:
```bash
kubectl get pod guaranteed-pod -o jsonpath='{.status.qosClass}'
# Output: Guaranteed
```

---

## QoS Classes Explained

**Guaranteed (highest priority):**
- Request == Limit for ALL resources
- Gets CPU exactly as requested
- Memory not killed until exceeds limit
- **Example:** `requests: cpu=500m, memory=512Mi` + same limits

**Burstable (medium priority):**
- Request < Limit (or requests without limits)
- Gets CPU when extra available
- Can be killed under memory pressure
- **Example:** `requests: cpu=100m` + `limits: cpu=200m`

**BestEffort (lowest priority):**
- No requests, no limits
- First to be killed under resource pressure
- **Example:** No resource section at all

**Priority under pressure:**
1. BestEffort killed first
2. Then Burstable
3. Guaranteed killed last

---

## Key Commands

```bash
# Create with resources
kubectl run <name> --image=<img> \
  --requests=cpu=<val>,memory=<val> \
  --limits=cpu=<val>,memory=<val>

# Check QoS class
kubectl get pod <name> -o jsonpath='{.status.qosClass}'

# Describe for full resource view
kubectl describe pod <name> | grep -A 5 "Limits\|Requests"

# Check node resource usage
kubectl top nodes
kubectl top pods
```

---

## Resource Units

**CPU:**
- `1` = 1 CPU core (1000m)
- `100m` = 0.1 CPU core (1/10)
- `500m` = 0.5 CPU core (1/2)

**Memory:**
- `128Mi` = 128 Mebibytes (2^20 bytes)
- `1Gi` = 1 Gibibyte (2^30 bytes)
- `1G` = 1 Gigabyte (10^9 bytes) - rarely used
