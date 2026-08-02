# CKA Command Reference

## Cluster Info
```bash
kubectl cluster-info
kubectl version --short
kubectl api-resources
kubectl api-versions
```

## Nodes
```bash
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl top nodes  # needs metrics-server
kubectl label node <name> key=value
kubectl taint nodes <name> key=value:NoSchedule
kubectl cordon <name>  # mark unschedulable
kubectl uncordon <name>
kubectl drain <name> --ignore-daemonsets
```

## Pods
```bash
kubectl run nginx --image=nginx --restart=Never
kubectl run nginx --image=nginx --restart=Always  # creates Deployment
kubectl get pods -A
kubectl get pods -o wide
kubectl describe pod <name>
kubectl logs <name>
kubectl logs <name> --previous
kubectl logs -f <name>
kubectl exec -it <name> -- sh
kubectl delete pod <name> --force --grace-period=0
kubectl debug -it <name> --image=nicolaka/netshoot --copy-to=pod-debug
```

## Deployments
```bash
kubectl create deployment nginx --image=nginx --replicas=3
kubectl scale deployment nginx --replicas=5
kubectl set image deployment/nginx nginx=nginx:1.25
kubectl rollout history deployment/nginx
kubectl rollout undo deployment/nginx
kubectl rollout status deployment/nginx
kubectl edit deployment nginx
```

## Services
```bash
kubectl expose pod nginx --port=80 --target-port=80
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc -A
kubectl describe svc <name>
```

## ConfigMaps/Secrets
```bash
kubectl create configmap my-config --from-literal=key=value --from-file=file.txt
kubectl create secret generic my-secret --from-literal=password=pass
kubectl get configmaps
kubectl get secrets
```

## Ingress
```bash
kubectl create ingress my-ing --rule="host.example.com/*=svc:80"
kubectl get ingress
```

## Storage
```bash
kubectl get pv
kubectl get pvc
kubectl get sc
```

## RBAC
```bash
kubectl create rolebinding <name> --clusterrole=admin --user=jane
kubectl create clusterrolebinding <name> --clusterrole=view --user=jane
kubectl auth can-i list pods --as=jane
kubectl auth can-i "*" "*" --as=system:anonymous
```

## Network Policies
```bash
kubectl get networkpolicies -A
```

## Events/Debug
```bash
kubectl get events -A --sort-by='.lastTimestamp'
kubectl get events -n <namespace>
kubectl cluster-info dump
```

## YAML Generation (dry-run)
```bash
kubectl run nginx --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > svc.yaml
```

## Imperative Quick Wins (exam time-savers)
```bash
# Pod with command
kubectl run busybox --image=busybox --restart=Never -- sleep 3600

# Multi-container pod
kubectl run multitool --image=busybox --restart=Never --dry-run=client -o yaml | \
  kubectl apply -f - -  # then edit to add second container

# CronJob
kubectl create cj hello --schedule="*/5 * * * *" --image=busybox -- echo hello

```

## kubectl plugins (if installed)
```bash
kubectl krew
kubectl get-alle
```

## kubeadm
```bash
kubeadm init
kubeadm join
kubeadm reset
kubeadm token create --print-join-command
```
