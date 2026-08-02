# Services & Ports - Q&A

## Questions & Answers

### Q: What are the 4 port types?
**A:**
| Port | Where | Range | Purpose |
|------|-------|-------|---------|
| **NodePort** | Node IP | 30000-32767 | External access |
| **Service Port** | ClusterIP | 1-65535 | Internal cluster access |
| **TargetPort** | Pod container | 1-65535 | Port app listens on |
| **containerPort** | Pod spec | 1-65535 | Documentation only |

---

### Q: What's the traffic flow?
**A:**
```
External: http://node-ip:30080
    ↓
NodePort: 30080 (on node)
    ↓
Service Port: 80 (ClusterIP)
    ↓
TargetPort: 80 (forwards to pod)
    ↓
Container: 80 (nginx listening)
```

---

### Q: Why did `kubectl create svc nodeport --tcp=30080:80` give random NodePort?
**A:** `create svc` doesn't let you specify NodePort. The first number becomes service port, not NodePort.

```bash
kubectl create svc nodeport web-svc --tcp=30080:80
# 30080 = service port (NOT NodePort!)
# NodePort assigned randomly
```

**Use `expose` to specify NodePort:**
```bash
kubectl expose deployment web --port=80 --node-port=30080
```

---

### Q: Does `create svc` automatically link to deployment?
**A:** NO! Creates orphan service:
```bash
kubectl create svc nodeport web-svc --tcp=80:80
# Service created BUT:
# - No selector
# - No endpoints
# - Not linked to any pods

kubectl get endpoints web-svc
# ENDPOINTS   <none>
```

**Use `expose` to auto-link:**
```bash
kubectl expose deployment web --port=80
# Creates service WITH selector
# selector:
#   app: web
```

---

### Q: How does service link to pods?
**A:** Through selector matching labels:
```
Deployment web:
  labels: app=web
  ↓ creates pods
  Pod-1: labels: app=web
  Pod-2: labels: app=web

Service web-svc:
  selector: app=web
  ↓ matches pods
  Endpoints: [10.244.1.5, 10.244.1.6]
```

---

### Q: What's the difference between port and targetPort?
**A:**
- **port**: Service port (what you call in cluster)
- **targetPort**: Container port (where traffic forwards to)

```yaml
ports:
- port: 80           # Call service on :80
  targetPort: 8080    # Forwards to container :8080
```

They can be different! Service exposes :80, app listens on :8080.

---

### Q: What is containerPort for?
**A:** Optional documentation field:
```yaml
containers:
- name: nginx
  ports:
  - containerPort: 80   # Just says "uses 80"
```

Doesn't affect routing! Just tells humans what port the app uses.

---

### Q: How to update image without opening YAML?
**A:** Use `kubectl set image`:
```bash
kubectl set image deployment/web nginx=nginx:1.28
#              ↑           ↑       ↑      ↑
#              │           │       │      └─ new image
#              │           │       └─ container name
#              │           └─ deployment name
#              └─ resource type
```

---

### Q: How to remove a taint?
**A:** Must match full taint spec:
```bash
kubectl taint nodes <node> key=value:effect-

# Example
kubectl taint nodes worker dedicated=prod:NoSchedule-
```

---

### Q: How does NodePort vs ClusterIP differ?
**A:**
- **ClusterIP**: Only accessible inside cluster
- **NodePort**: Accessible from outside via `node-ip:nodePort`

NodePort is just ClusterIP exposed on nodes.

## Key Commands
```bash
# Expose with specific NodePort
kubectl expose deployment web --port=80 --target-port=80 --type=NodePort --node-port=30080

# Update image
kubectl set image deployment/<name> <container>=<image>

# Remove taint
kubectl taint nodes <node> key=value:effect-

# Check endpoints
kubectl get endpoints <service-name>

# Check service details
kubectl describe svc <service-name>
```
