# Scenario 21: Solution

## Solution

### 1. Check CoreDNS pods

```bash
# Find CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Or by name
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS pod health
kubectl describe pod -n kube-system -l k8s-app=kube-dns
```

### 2. Check CoreDNS service

```bash
# Find CoreDNS service
kubectl get svc -n kube-system kube-dns

# Get the ClusterIP (DNS server for pods)
kubectl get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}'

# Describe service
kubectl describe svc kube-dns -n kube-system
```

### 3. Test DNS resolution from pod

```bash
# Create debug pod
kubectl run dns-debug --image=busybox --restart=Never -it -- sh

# Inside pod, test DNS:
nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc
nslookup dns-test.default.svc.cluster.local
nslookup dns-test.default.svc
nslookup dns-test

# Check resolv.conf
cat /etc/resolv.conf
# Should show:
# search default.svc.cluster.local svc.cluster.local cluster.local
# nameserver <CoreDNS ClusterIP>
# options ndots:5
```

### 4. Debug DNS failure

```bash
# Check 1: CoreDNS pods running
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check 2: CoreDNS service exists
kubectl get svc kube-dns -n kube-system

# Check 3: Pod DNS config
kubectl exec <pod> -- cat /etc/resolv.conf

# Check 4: Test DNS from working pod
kubectl run dns-check --image=busybox --restart=Never -- rm -f -- \
  nslookup <service-name>.<namespace>

# Check 5: CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

## DNS Record Types

**Service DNS:**
- `my-service.my-ns.svc.cluster.local` → Service ClusterIP
- `my-service.my-ns.svc` → Service ClusterIP
- `my-service` → (in my-ns namespace) Service ClusterIP

**Pod DNS:**
- `10-0-0-1.my-ns.pod.cluster.local` → Pod IP (if enabled)
- Format: `{pod-ip-replaced-with-dashes}.{namespace}.pod.cluster.local`

**Headless Service:**
- Returns Pod IPs instead of Service IP
- Used for StatefulSets

**External Name:**
- CNAME alias to external DNS name

---

## Debugging DNS Issues

**Common causes:**
1. **CoreDNS not running** → Restart or fix CoreDNS pods
2. **Wrong DNS server** → Check `/etc/resolv.conf`
3. **Service doesn't exist** → Check service name/namespace
4. **Search domain issues** → Check `search` line in resolv.conf
5. **ndots setting** → Affects how names are resolved

**Quick tests:**
```bash
# Can I resolve cluster services?
kubectl run test --image=busybox --rm -it -- nslookup kubernetes.default

# Can I resolve my service?
kubectl run test --image=busybox --rm -it -- nslookup my-service.default

# Full DNS path (should always work)
kubectl run test --image=busybox --rm -it -- nslookup my-service.default.svc.cluster.local
```

---

## Exam Tips

**Common exam task:** "Pod can't reach service by name, fix it"

**Debug steps:**
1. Check `/etc/resolv.conf` in pod
2. Check CoreDNS pods running
3. Check service exists and has correct name
4. Test DNS from debug pod

**DNS in kube-dns service:**
```bash
kubectl get svc kube-dns -n kube-system
# ClusterIP is the DNS server for all pods
```
