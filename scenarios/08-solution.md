# Solution 08: Ingress

```bash
# 1. Create deployment and service
kubectl create deployment web --image=nginx:alpine --replicas=2
kubectl expose deployment web --port=80 --name=web-svc

# 2. Create Ingress (imperative)
kubectl create ingress web-ing \
  --class=nginx \
  --rule="web.example.com/*=web-svc:80"

# OR with YAML
cat > web-ing.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ing
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
EOF

kubectl apply -f web-ing.yaml

# 3. Verify
kubectl get ingress web-ing
kubectl describe ingress web-ing
```

## Cleanup

```bash
kubectl delete ingress web-ing
kubectl delete service web-svc
kubectl delete deployment web
rm web-ing.yaml
```
