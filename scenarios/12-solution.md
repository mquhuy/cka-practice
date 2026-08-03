# Scenario 12: Solution

## Solution

### 1. Find etcd pod
```bash
kubectl get pods -n kube-system | grep etcd

# Output:
# cka-practice-control-plane-xxx   1/1     Running   ...   etcd
```

### 2. Check etcd version
```bash
kubectl get pods -n kube-system -o jsonpath='{.items[?(@.metadata.name=="etcd")].spec.containers[0].image}' | grep -o 'etcd:.*'

# Or describe the pod:
kubectl describe pod -n kube-system -l component=etcd
```

### 3. Create etcd backup

**For kubeadm clusters (exam environment):**
```bash
# SSH to control plane node first (in exam)
# Then run:

ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
```

**For kind clusters (local practice):**
```bash
# Access etcd via Docker
docker exec -it cka-practice-control-plane \
  /bin/sh -c "ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db"

# Copy out of container
docker cp cka-practice-control-plane:/tmp/etcd-backup.db /tmp/etcd-backup.db
```

### 4. Verify backup
```bash
# Check file exists
ls -la /tmp/etcd-backup.db

# Check file size (should be several MB)
du -h /tmp/etcd-backup.db
```

### 5. List snapshot status
```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot status /tmp/etcd-backup.db
```

Output shows:
- Hash
- Revision
- Total keys
- Total size

---

## Full Restore Process (Reference)

**Not tested in this scenario, but important to know:**

```bash
# 1. Stop control plane static pods
mv /etc/kubernetes/manifests/etcd.yaml /tmp/
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
mv /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp/
mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

# 2. Restore from snapshot
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 3. Move manifests back
mv /tmp/etcd.yaml /etc/kubernetes/manifests/
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
mv /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests/
mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/

# 4. Verify cluster is back
kubectl get nodes
```

---

## Key Points for Exam

**Backup command (memorize):**
```bash
ETCDCTL_API=3 etcdctl snapshot save <file> \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=<ca-file> \
  --cert=<cert-file> \
  --key=<key-file>
```

**Standard paths (kubeadm):**
- CA: `/etc/kubernetes/pki/etcd/ca.crt`
- Cert: `/etc/kubernetes/pki/etcd/server.crt`
- Key: `/etc/kubernetes/pki/etcd/server.key`

**Steps in exam:**
1. SSH to control plane
2. Run backup command
3. Verify backup created

**Restore:**
- Stop static pods first
- Restore creates new data directory
- Restart static pods
