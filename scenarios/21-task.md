# Scenario 21: CoreDNS & Service Discovery

**Time:** 6 minutes | **Difficulty:** Medium

---

## Context

CoreDNS provides DNS-based service discovery. Pods use DNS to find Services. Debugging DNS issues is common exam task.

---

## Prerequisites

```bash
# Create test deployment and service
kubectl create deployment dns-test --image=nginx
kubectl expose deployment dns-test --port=80
```

---

## Tasks

### 1. Check CoreDNS pods
Verify CoreDNS is running in `kube-system` namespace.

### 2. Check CoreDNS service
Find the CoreDNS service and its ClusterIP.

### 3. Test DNS resolution from pod
Create pod `dns-debug` with `busybox`:
- Test DNS resolution for:
  - `kubernetes.default.svc.cluster.local` (cluster DNS)
  - `dns-test.default.svc.cluster.local` (service DNS)
  - `dns-test.default.svc` (short form)
  - `dns-test` (same namespace only)

### 4. Debug DNS failure (simulated)
Given a pod that can't resolve service names:
- Check `/etc/resolv.conf` in pod
- Check CoreDNS pods are healthy
- Check CoreDNS service exists

---

## Hints

<details>
<summary>DNS record formats</summary>

```
<service-name>.<namespace>.svc.cluster.local  # Full FQDN
<service-name>.<namespace>.svc                 # Shorter
<service-name>                                 # Same namespace only
```
</details>

<details>
<summary>Check pod DNS config</summary>

```bash
kubectl exec <pod> -- cat /etc/resolv.conf
```
</details>

<details>
<summary>Common DNS issues</summary>

- CoreDNS pods not running
- Wrong cluster DNS in `/etc/resolv.conf`
- Service name wrong
- Namespace mismatch
</details>

---

## Verification

```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get svc -n kube-system kube-dns

# Test DNS from pod
kubectl exec dns-debug -- nslookup kubernetes.default.svc.cluster.local
kubectl exec dns-debug -- nslookup dns-test.default.svc

# Check DNS service
kubectl get svc kube-dns -n kube-system
```
