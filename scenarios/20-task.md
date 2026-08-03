# Scenario 20: ServiceAccounts & RBAC Integration

**Time:** 6 minutes | **Difficulty:** Medium

---

## Context

Pods use ServiceAccounts to authenticate with the API server. Link ServiceAccounts to Roles for pod permissions.

---

## Tasks

### 1. Create ServiceAccount
Create ServiceAccount named `pod-sa` in `default` namespace.

### 2. Create Role for pod operations
Create Role `pod-role` with permissions:
- **get, list** pods
- **get, list** services
- In `default` namespace only

### 3. Create RoleBinding
Bind `pod-role` to ServiceAccount `pod-sa`:
- RoleBinding: `pod-rolebinding`
- Links SA to Role

### 4. Create pod using ServiceAccount
Create pod `sa-test-pod`:
- Uses ServiceAccount `pod-sa`
- Runs `busybox` with command `sleep 3600`
- Verify pod can list pods and services

---

## Hints

<details>
<summary>ServiceAccount creation</summary>

```bash
kubectl create serviceaccount pod-sa
```
</details>

<details>
<summary>Role with resources and verbs</summary>

```bash
kubectl create role pod-role \
  --verb=get,list --resource=pods,services
```
</details>

<details>
<summary>RoleBinding linking SA to Role</summary>

```bash
kubectl create rolebinding pod-rolebinding \
  --role=pod-role --serviceaccount=default:pod-sa
```
</details>

<details>
<summary>Pod with ServiceAccount</summary>

```yaml
spec:
  serviceAccountName: pod-sa
  containers:
  - name: test
    image: busybox
```
</details>

---

## Verification

```bash
# Check SA created
kubectl get sa pod-sa

# Check Role/RoleBinding
kubectl get role,rolebinding

# Test pod permissions
kubectl exec sa-test-pod -- kubectl get pods
kubectl exec sa-test-pod -- kubectl get svc

# Try denied action (should fail)
kubectl exec sa-test-pod -- kubectl get deployments
```
