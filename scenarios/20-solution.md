# Scenario 20: Solution

## Solution

### 1. Create ServiceAccount

```bash
kubectl create serviceaccount pod-sa

# Verify
kubectl get sa pod-sa
kubectl describe sa pod-sa
```

### 2. Create Role for pod operations

```bash
kubectl create role pod-role \
  --verb=get,list \
  --resource=pods,services

# Verify
kubectl describe role pod-role
```

### 3. Create RoleBinding

```bash
kubectl create rolebinding pod-rolebinding \
  --role=pod-role \
  --serviceaccount=default:pod-sa

# Verify
kubectl get rolebinding pod-rolebinding
kubectl describe rolebinding pod-rolebinding
```

### 4. Create pod using ServiceAccount

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: sa-test-pod
spec:
  serviceAccountName: pod-sa
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
EOF
```

### 5. Test permissions

```bash
# Create a token-based kubectl config for the pod
TOKEN=$(kubectl create token pod-sa -n default)
kubectl exec sa-test-pod -- sh -c "kubectl get pods --token=$TOKEN"

# Or from within pod (if kubectl binary available)
kubectl exec sa-test-pod -- kubectl auth can-i get pods
# Output: yes

kubectl exec sa-test-pod -- kubectl auth can-i delete pods
# Output: no

kubectl exec sa-test-pod -- kubectl get services
# Output: SERVICES LISTED
```

---

## Key Concepts

**ServiceAccount:**
- Identity for pods (like user account for humans)
- Each pod gets default ServiceAccount
- Mounted at `/var/run/secrets/kubernetes.io/serviceaccount/`
- Contains: token, ca.crt, namespace

**RBAC for ServiceAccounts:**
```bash
# Format: --serviceaccount=<namespace>:<sa-name>
kubectl create rolebinding <name> \
  --role=<role> \
  --serviceaccount=default:pod-sa
```

**Pod ServiceAccount Field:**
```yaml
spec:
  serviceAccountName: pod-sa  # Explicit SA
  # If omitted: uses "default" SA in namespace
```

**Permission Checking:**
```bash
# Check what SA can do
kubectl auth can-i get pods --as=system:serviceaccount:default:pod-sa

# Check from within pod
kubectl auth can-i list pods
```

---

## Exam Tips

**Common task:** "Create SA, give it permissions to view pods, create pod using that SA"

**Steps:**
1. `kubectl create sa <name>`
2. `kubectl create role <role> --verb=get,list --resource=pods`
3. `kubectl create rolebinding <rb> --role=<role> --serviceaccount=default:<sa>`
4. Create pod with `serviceAccountName: <sa>`

**Automatic token mounting:**
- Pod gets SA token automatically
- No need to specify volumes
- Token auto-rotated

**Default ServiceAccount:**
- Every namespace has `default` SA
- If not specified, pods use `default` SA
- `default` SA typically has no permissions
