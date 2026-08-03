# Scenario 13: Resource Limits & Requests

**Time:** 5 minutes | **Difficulty:** Easy

---

## Context

Pods need resource specifications for proper scheduling and QoS. You'll set requests and limits on containers.

---

## Tasks

### 1. Create pod with resources
Create a pod named `resource-pod` with:
- Image: `nginx`
- CPU request: 100m
- CPU limit: 200m
- Memory request: 128Mi
- Memory limit: 256Mi

### 2. Verify resource allocation
Check that the pod has the correct resource requests and limits.

### 3. Check QoS class
Determine the QoS (Quality of Service) class of the pod.

### 4. Create a Guaranteed QoS pod
Create a pod named `guaranteed-pod` with:
- Image: `redis`
- CPU request = limit: 500m
- Memory request = limit: 512Mi
- Verify it has Guaranteed QoS class

---

## Hints

<details>
<summary>Imperative command with resources</summary>

```bash
kubectl run resource-pod --image=nginx --restart=Never \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi --dry-run=client -o yaml > pod.yaml
kubectl apply -f pod.yaml
```
</details>

<details>
<summary>Check QoS class</summary>

```bash
kubectl get pod resource-pod -o jsonpath='{.status.qosClass}'

# Or view full pod yaml
kubectl get pod resource-pod -o yaml | grep qosClass
```
</details>

<details>
<summary>QoS classes</summary>

- **Guaranteed**: request == limit for all resources
- **Burstable**: requests < limits (or requests set, no limits)
- **BestEffort**: no requests, no limits
</details>

---

## Verification

```bash
# Check resource allocation
kubectl describe pod resource-pod | grep -A 2 "Requests\|Limits"

# Check QoS class
kubectl get pod resource-pod -o jsonpath='{.status.qosClass}'

# Verify Guaranteed QoS
kubectl get pod guaranteed-pod -o jsonpath='{.status.qosClass}'
```
