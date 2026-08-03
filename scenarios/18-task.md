# Scenario 18: StatefulSet & Headless Service

**Time:** 8 minutes | **Difficulty:** Hard

---

## Tasks

### 1. Create StatefulSet
Create StatefulSet named `web` with:
- Image: `nginx`
- **3 replicas** (ordered deployment: web-0, web-1, web-2)
- Headless service `web` (ClusterIP: None)
- Each pod gets stable network identity: `web-0.web`, `web-1.web`, etc.

### 2. Create PersistentVolume for each pod
- Each pod gets its own PVC (web-0, web-1, web-2)
- Use PVC template in StatefulSet
- 1Gi each, access mode ReadWriteOnce

### 3. Verify StatefulSet behavior
- Check pods created in order
- Verify stable network names
- Check PVCs created per pod

### 4. Test ordered scaling
- Scale down to 2 replicas (highest terminates first)
- Scale back to 3 (terminated pod recreated with same identity)

---

## Hints

<details>
<summary>StatefulSet YAML structure</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None  # Headless
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
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```
</details>

<details>
<summary>StatefulSet vs Deployment</summary>

- **Ordered deployment**: 0, 1, 2... (not parallel)
- **Stable network ID**: pod-0.service, pod-1.service...
- **Stable storage**: PVC per pod, persists across rescheduling
- **Ordered termination**: Highest terminates first
</details>

---

## Verification

```bash
# Check StatefulSet status
kubectl get statefulset web

# Check pods (note ordered naming)
kubectl get pods -l app=nginx

# Check stable DNS (within pod)
kubectl exec web-0 -- nslookup web-1.web

# Check PVCs
kubectl get pvc

# Scale StatefulSet
kubectl scale statefulset web --replicas=2
kubectl scale statefulset web --replicas=3
```
