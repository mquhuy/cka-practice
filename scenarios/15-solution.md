# Scenario 15: Solution

## Solution

### 1. Check deployment availability
```bash
# Create deployment if needed
kubectl create deployment web-app --image=nginx --replicas=5

# Check replicas
kubectl get deployment web-app
kubectl get pods -l app=web-app

# Should show 5 Running
```

### 2. Create PDB

**Method 1: YAML (recommended for exam)**
```bash
kubectl apply -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: web-app
EOF
```

**Method 2: Using labels from deployment**
```bash
# First get deployment labels
kubectl get deployment web-app -o jsonpath='{.spec.template.metadata.labels}'

# Create PDB
kubectl create pdb web-pdb --min-available=3 \
  --selector=app=web-app
```

**Alternative with maxUnavailable:**
```bash
kubectl apply -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: web-app
EOF
```

### 3. Verify PDB created
```bash
# List all PDBs
kubectl get pdb

# Describe specific PDB
kubectl describe pdb web-pdb

# Check full YAML
kubectl get pdb web-pdb -o yaml
```

### 4. Test PDB behavior
```bash
# See how many pods could be disrupted
kubectl get pdb web-pdb -o jsonpath='{.status.disruptionsAllowed}'

# With minAvailable: 3, 5 replicas → can disrupt 2
# With maxUnavailable: 1, any replicas → can disrupt 1

# To test drain behavior (understanding only):
kubectl cordon <node-with-pods>
kubectl drain <node-with-pods> --dry-run=client
# Would respect PDB - only evict up to disruptionsAllowed
```

### 5. Check PDB status
```bash
# Full status
kubectl get pdb web-pod -o yaml

# Key fields:
# .status.disruptionsAllowed - How many can be disrupted
# .status.currentHealthy - Current healthy pods
# .status.desiredHealthy - Minimum required healthy
# .status.expectedPods - Total pods matching selector

# Quick check
kubectl get pdb web-pdb
```

Output example:
```
NAME     MIN AVAILABLE   ALLOWED DISRUPTIONS   AGE
web-pdb   3              2                     1m
```

---

## Key Concepts

**PodDisruptionBudget Purpose:**
- Limits voluntary disruptions (node drain, node upgrade)
- Does NOT protect from involuntary disruptions (node crash, pod crash)
- Ensures minimum availability during maintenance

**minAvailable vs maxUnavailable:**
- `minAvailable: 3` = At least 3 pods must run
- `maxUnavailable: 1` = At most 1 pod can be down
- Can use percentages: `minAvailable: "80%"`

**Examples:**
```yaml
# At least 80% must remain
spec:
  minAvailable: "80%"

# At most 1 can be down
spec:
  maxUnavailable: 1

# Absolute numbers
spec:
  minAvailable: 2
```

**How it works with drain:**
1. `kubectl drain` checks PDB
2. Evicts pods up to `disruptionsAllowed`
3. If PDB blocks, drain fails with message
4. Admin must retry or force

---

## Exam Tips

**Common scenario:**
```bash
# Given deployment with N replicas
# Create PDB ensuring X pods always available

kubectl create pdb my-pdb \
  --selector=app=myapp \
  --min-available=3
```

**Check PDB is working:**
```bash
kubectl get pdb
kubectl describe pdb <name>
```

**Remember:**
- PDB selector must match pod labels
- PDB only affects voluntary disruptions
- `disruptionsAllowed` = current - minAvailable
- Used with `kubectl drain` and `kubectl delete`
