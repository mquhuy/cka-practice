# Scenario 12: etcd Backup & Restore

**Time:** 8 minutes | **Difficulty:** Hard

---

## Context

You need to backup the etcd database from the control plane node and understand the restore process. This is critical for disaster recovery.

---

## Tasks

### 1. Find etcd pod
Find the etcd pod running in the `kube-system` namespace.

### 2. Check etcd version
Verify the etcd version running in your cluster.

### 3. Create etcd backup
Create a snapshot backup of etcd to `/tmp/etcd-backup.db`.

**Required parameters:**
- Endpoints: https://127.0.0.1:2379
- CA file: `/etc/kubernetes/pki/etcd/ca.crt`
- Cert file: `/etc/kubernetes/pki/etcd/server.crt`
- Key file: `/etc/kubernetes/pki/etcd/server.key`

### 4. Verify backup
Verify the backup file was created and check its status.

### 5. List snapshot status
Use `etcdctl snapshot status` to view information about the backup.

---

## Hints

<details>
<summary>Find etcd pod</summary>

```bash
kubectl get pods -n kube-system | grep etcd
```
</details>

<details>
<summary>etcdctl command structure</summary>

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
```
</details>

<details>
<summary>Accessing etcd pod</summary>

For kind clusters, etcd runs as a container on the node. You may need to access it differently depending on your cluster setup.
</details>

---

## Notes

**Important for exam:**
- `ETCDCTL_API=3` ensures you use v3 API
- Paths are standard for kubeadm clusters
- In exam, you'll SSH to control plane first
- Backup command doesn't need `kubectl exec` in real clusters

**Restore process (not tested here):**
1. Stop API server (and controller, scheduler)
2. Run `etcdctl snapshot restore`
3. Restart static pods

---

## Verification

```bash
# Check backup file exists
ls -la /tmp/etcd-backup.db

# Check snapshot status
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot status /tmp/etcd-backup.db
```
