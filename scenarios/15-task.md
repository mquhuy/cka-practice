# Scenario 15: PodDisruptionBudget

**Time:** 7 minutes | **Difficulty:** Hard

---

## Context

PodDisruptionBudget (PDB) limits pod disruptions during voluntary disruptions (like node drains). It ensures minimum availability during maintenance.

---

## Prerequisites

Deploy an application first:
```bash
kubectl create deployment web-app --image=nginx --replicas=5
```

---

## Tasks

### 1. Check deployment availability
Verify the deployment has 5 replicas running.

### 2. Create PDB
Create a PodDisruptionBudget named `web-pdb` for the `web-app` deployment:
- **Minimum available**: 3 pods
- OR **Maximum unavailable**: 1 pod

Use whichever approach you prefer.

### 3. Verify PDB created
Check that the PDB is correctly configured.

### 4. Test PDB behavior
Simulate what happens when draining a node with these pods:
- Check how many pods can be disrupted
- Verify PDB prevents complete pod loss

### 5. Check PDB status
View current PDB status and allowed disruptions.

---

## Hints

<details>
<summary>PDB YAML structure</summary>

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: web-app
```
</details>

<details>
<summary>Imperative creation</summary>

```bash
kubectl create pdb web-pdb --min-available=3 \
  --selector=app=web-app
```
</details>

<details>
<summary>PDB modes</summary>

- `minAvailable: X` - At least X pods must remain
- `maxUnavailable: X` - At most X pods can be down
- Can use percentage: `minAvailable: "80%"`
</details>

---

## Verification

```bash
# Check PDB status
kubectl get pdb
kubectl describe pdb web-pdb

# Check allowed disruptions
kubectl get pdb web-pdb -o jsonpath='{.status.disruptionsAllowed}'

# View PDB YAML
kubectl get pdb web-pdb -o yaml
```
