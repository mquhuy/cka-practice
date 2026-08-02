# Scenario: CrashLoopBackOff Troubleshooting

## Objective
Debug and fix a pod stuck in CrashLoopBackOff.

## Setup (run first)
```bash
# Create broken pod
cat > broken-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: broken-app
spec:
  containers:
  - name: app
    image: alpine
    command: ["/bin/sh", "-c"]
    args: ["exit 1"]  # Broken: always exits
EOF

kubectl apply -f broken-pod.yaml
```

## Tasks
1. Identify the pod is in CrashLoopBackOff
2. Check logs (see exit 1 error)
3. Check events (see repeated crashes)
4. Fix the pod to run successfully
5. Verify it stays Running

## Solution
```bash
# 1. Check status
kubectl get pods
kubectl describe pod broken-app | grep -A5 State:

# 2. Check logs
kubectl logs broken-app
kubectl logs broken-app --previous  # see previous attempt

# 3. Check events
kubectl get events --sort-by='.lastTimestamp'
kubectl describe pod broken-app | grep -A20 Events:

# 4. Fix - change to successful command
kubectl run fixed-app --image=alpine --restart=Never -- sleep 3600

# OR edit the pod
kubectl edit pod broken-app
# Change args to: ["sleep", "3600"]

# 5. Verify
kubectl get pods
```

## Cleanup
```bash
kubectl delete pod broken-app fixed-app --force --grace-period=0
```

## Key Commands
- `kubectl logs <pod>` - current container logs
- `kubectl logs <pod> --previous` - previous container logs
- `kubectl describe pod <pod>` - detailed state and events
- `kubectl get events` - cluster events
