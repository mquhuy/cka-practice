# Solution 09: Scheduling

```bash
# 1. Label nodes
kubectl label node cka-practice-worker env=prod
kubectl label node cka-practice-worker2 env=dev

# 2. Pod with node selector
kubectl run prod-app --image=nginx:alpine --restart=Never --node-selector=env=prod
kubectl get pods -o wide

# 3. Pod with affinity (YAML)
cat > affinity-pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: affinity-app
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - prod
  containers:
  - name: nginx
    image: nginx:alpine
EOF

kubectl apply -f affinity-pod.yaml

# 4. Taint node
kubectl taint nodes cka-practice-worker dedicated=prod:NoSchedule

# 5. Pod with toleration
kubectl run toleration-app --image=nginx:alpine --restart=Never \
  --overrides='
{
  "spec": {
    "tolerations": [{
      "key": "dedicated",
      "operator": "Equal",
      "value": "prod",
      "effect": "NoSchedule"
    }],
    "nodeSelector": {"env": "prod"}
  }
}'

# Verify
kubectl get pods -o wide
```

## Cleanup

```bash
kubectl delete pod prod-app affinity-app toleration-app
kubectl label node cka-practice-worker env-
kubectl label node cka-practice-worker2 env-
kubectl taint nodes cka-practice-worker dedicated:NoSchedule-
rm affinity-pod.yaml
```
