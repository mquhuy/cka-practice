# CKA Mock Exam Drill #2

## Exam Rules (simulated)
- **Time limit**: 25 minutes
- **Domains**: Storage, RBAC, Troubleshooting
- **Weighted**: 35% total
- **Context**: `kind-cka-practice`

---

## Task 1: PersistentVolume (Weight: 10%)
**Time: 8 minutes**

Create static PV and PVC:
1. PV named `logs-pv`:
   - 5Gi storage
   - Access mode: ReadWriteOnce
   - StorageClass: `manual` (no provisioner)
   - HostPath: `/tmp/logs` (on any node)
2. PVC named `logs-pvc`:
   - Request: 2Gi
   - Access mode: ReadWriteOnce
3. Verify PVC binds to PV

<details>
<summary>Solution</summary>

```bash
# Create PV
cat > logs-pv.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: logs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/logs
EOF

kubectl apply -f logs-pv.yaml

# Create PVC
cat > logs-pvc.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logs-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: manual
EOF

kubectl apply -f logs-pvc.yaml

# Verify bound
kubectl get pv,pvc
kubectl get pvc logs-pvc -o jsonpath='{.status.phase}'
```
</details>

---

## Task 2: RBAC (Weight: 8%)
**Time: 7 minutes**

Create limited access for user `jane`:
1. Create Role `pod-reader` in namespace `development` (create ns too):
   - Can get, list, watch pods
   - Cannot create/delete/update
2. Create RoleBinding `jane-pod-read` binding Role to user `jane`
3. Verify access: `kubectl auth can-i get pods -n development --as=jane` should return yes
4. Verify denied: `kubectl auth can-i delete pods -n development --as=jane` should return no

<details>
<summary>Solution</summary>

```bash
# Create namespace
kubectl create namespace development

# Create Role
kubectl create role pod-reader \
  --namespace=development \
  --verb=get,list,watch \
  --resource=pods

# Verify role
kubectl describe role pod-reader -n development

# Create RoleBinding
kubectl create rolebinding jane-pod-read \
  --namespace=development \
  --role=pod-reader \
  --user=jane

# Verify access
kubectl auth can-i get pods -n development --as=jane
kubectl auth can-i list pods -n development --as=jane
kubectl auth can-i delete pods -n development --as=jane
```
</details>

---

## Task 3: Troubleshooting (Weight: 10%)
**Time: 10 minutes**

**Situation**: Deployment `api` runs 3 replicas but pods keep crashing.

Given broken pod spec (run setup first):
```bash
kubectl run api --image=alpine --restart=Never --command -- /bin/sh -c "exit 1"
```

Tasks:
1. Identify pod is CrashLoopBackOff
2. Find root cause using logs/describe/events
3. Fix by creating correct deployment with:
   - Image `nginx:alpine`
   - Proper liveness/readiness probes
   - Resource limits (cpu: 100m, memory: 128Mi)
4. Verify deployment runs 3 healthy replicas

<details>
<summary>Solution</summary>

```bash
# Setup broken pod
kubectl run api --image=alpine --restart=Never --command -- /bin/sh -c "exit 1"

# 1. Check status
kubectl get pods
kubectl describe pod api | grep State

# 2. Debug
kubectl logs api
kubectl logs api --previous
kubectl get events --sort-by='.lastTimestamp'

# 3. Create fixed deployment
kubectl create deployment api --image=nginx:alpine --replicas=3 --dry-run=client -o yaml > api-deploy.yaml

# Edit to add probes and resources (or use imperative)
kubectl create deployment api --image=nginx:alpine --replicas=3
kubectl set resources deployment/api --limits=cpu=100m,memory=128Mi

# Or full YAML with probes:
cat > api-fixed.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        resources:
          limits:
            cpu: "100m"
            memory: "128Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 3
EOF

kubectl apply -f api-fixed.yaml
kubectl delete pod api --force --grace-period=0 2>/dev/null

# 4. Verify
kubectl get deployment api
kubectl get pods -l app=api
```
</details>

---

## Task 4: ConfigMap (Weight: 7%)
**Time: 5 minutes**

Create ConfigMap and mount to pod:
1. ConfigMap `app-config` with:
   - `database.url=postgres://localhost:5432`
   - `cache.ttl=60s`
2. Pod `config-test` mounting ConfigMap as volume at `/etc/config`
3. Verify file exists in pod with correct content

<details>
<summary>Solution</summary>

```bash
# Create ConfigMap
kubectl create configmap app-config \
  --from-literal=database.url=postgres://localhost:5432 \
  --from-literal=cache.ttl=60s

# Verify
kubectl get configmap app-config -o yaml

# Create pod with volume
kubectl run config-test --image=busybox --restart=Never \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "main",
      "image": "busybox",
      "command": ["sleep", "3600"],
      "volumeMounts": [{
        "name": "config",
        "mountPath": "/etc/config"
      }]
    }],
    "volumes": [{
      "name": "config",
      "configMap": {"name": "app-config"}
    }]
  }
}'

# Verify
kubectl exec config-test -- cat /etc/config/database.url
kubectl exec config-test -- cat /etc/config/cache.ttl
```
</details>

---

## Scoring
```
Task 1: 10% (PV/PVC)
Task 2: 8% (RBAC)
Task 3: 10% (Troubleshooting)
Task 4: 7% (ConfigMap)
---
Total: 35%
```

## Timer
```bash
./timer.sh
```

## Cleanup
```bash
kubectl delete -n development rolebinding jane-pod-read role pod-reader
kubectl delete namespace development
kubectl delete deployment api pod api config-test
kubectl delete pvc logs-pvc pv logs-pv
kubectl delete configmap app-config
```
