# Task 09: Scheduling - Node Affinity, Taints, Tolerations

Control pod placement.

## Requirements

1. Label nodes:
   - `cka-practice-worker`: `env=prod`
   - `cka-practice-worker2`: `env=dev`
2. Create pod `prod-app` with node selector `env=prod`
3. Create pod with PREFERRED affinity for `env=prod` (weight 100)
4. Taint prod node: `dedicated=prod:NoSchedule`
5. Create pod with toleration for the taint

## Verification

```bash
kubectl get nodes -L env
kubectl get pods -o wide
kubectl describe nodes | grep -A5 Taints
```

## Hints

- `kubectl label node` to add labels
- `kubectl run` with `--node-selector`
- For affinity, use YAML with `affinity.nodeAffinity`
- `kubectl taint nodes` to add taints
- Tolerations in pod spec under `spec.tolerations`
