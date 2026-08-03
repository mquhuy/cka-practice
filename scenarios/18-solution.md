# Scenario 18: Solution

## Solution

### 1. Create StatefulSet with Headless Service

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF
```

### 2. Verify creation

```bash
# Watch pods start sequentially
kubectl get pods -l app=nginx -w

# Should see: web-0 (running), then web-1, then web-2

# Check StatefulSet
kubectl get statefulset web

# Check PVCs created automatically
kubectl get pvc
```

### 3. Verify StatefulSet behavior

```bash
# Check stable DNS (from within cluster)
kubectl exec web-0 -- nslookup web-1.web.default.svc.cluster.local

# Or simpler:
kubectl exec web-0 -- ping -c 2 web-1.web

# Check pod identity persists
kubectl delete pod web-1
# New web-1 gets same PVC and identity
kubectl get pvc  # www-web-1 still there
```

### 4. Test ordered scaling

```bash
# Scale down
kubectl scale statefulset web --replicas=2

# web-2 terminates first
kubectl get pods -l app=nginx -w

# Scale back up
kubectl scale statefulset web --replicas=3

# web-2 recreated with same identity and PVC
kubectl get pods -l app=nginx
kubectl get pvc
```

---

## Key Concepts

**StatefulSet Characteristics:**
- **Ordered deployment**: web-0 → web-1 → web-2
- **Ordered termination**: web-2 → web-1 → web-0
- **Stable network IDs**: pod-name.service-name.ns.svc.cluster.local
- **Stable storage**: PVC per pod, persists across pod lifecycle

**Headless Service:**
- `clusterIP: None`
- DNS returns all pod IPs (not single service IP)
- Required for StatefulSet stable networking

**volumeClaimTemplates:**
- Template for PVC creation
- One PVC per pod
- PVC named: `{templateName}-{pod-name}`
- PVC persists when pod deleted/recreated

**Common Use Cases:**
- Databases (MySQL, PostgreSQL)
- Distributed systems (etcd, ZooKeeper)
- Any app requiring stable identity + storage

---

## Exam Tips

**StatefulSet scaling:**
```bash
kubectl scale statefulset web --replicas=5
# Creates web-3, web-4 in order
```

**Delete StatefulSet = deletes pods but NOT PVCs:**
```bash
kubectl delete statefulset web
kubectl get pvc  # PVCs still there
```

**Delete everything:**
```bash
kubectl delete statefulset web
kubectl delete pvc -l app=nginx
```

**Headless service for StatefulSet is REQUIRED** - don't forget it!
