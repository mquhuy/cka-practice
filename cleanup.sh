#!/bin/bash
# CKA Cluster Cleanup - Safe cleanup for practice scenarios
# Usage: ./cleanup.sh

CLUSTER_CTX="kind-cka-practice"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Cleaning practice resources${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# List of user namespaces to clean (add your practice namespaces here)
USER_NAMESPACES="default frontend backend development prod"

echo -e "${YELLOW}Cleaning user namespaces...${NC}"
for ns in $USER_NAMESPACES; do
    # Skip if namespace doesn't exist
    if kubectl --context="$CLUSTER_CTX" get namespace "$ns" &>/dev/null; then
        echo "  Cleaning: $ns"
        kubectl --context="$CLUSTER_CTX" delete pods,deployments,services,ingress,networkpolicies,pvc,configmap,secret,jobs,cronjobs,statefulsets,daemonsets,rolebindings,roles,serviceaccounts,horizontalpodautoscaler -n "$ns" --all --ignore-not-found=true 2>/dev/null
    fi
done

echo ""
echo -e "${YELLOW}Cleaning nodes...${NC}"
nodes=$(kubectl --context="$CLUSTER_CTX" get nodes -o jsonpath='{.items[*].metadata.name}')
for node in $nodes; do
    # Remove common practice labels
    kubectl --context="$CLUSTER_CTX" label node "$node" env- 2>/dev/null || true
    kubectl --context="$CLUSTER_CTX" label node "$node" dedicated- 2>/dev/null || true
    kubectl --context="$CLUSTER_CTX" label node "$node" tier- 2>/dev/null || true
    # Remove common practice taints (with values)
    kubectl --context="$CLUSTER_CTX" taint nodes "$node" dedicated=prod:NoSchedule- 2>/dev/null || true
    kubectl --context="$CLUSTER_CTX" taint nodes "$node" dedicated=dev:NoSchedule- 2>/dev/null || true
    kubectl --context="$CLUSTER_CTX" taint nodes "$node" dedicated:NoSchedule- 2>/dev/null || true
    kubectl --context="$CLUSTER_CTX" taint nodes "$node" key:NoSchedule- 2>/dev/null || true
    # Uncordon
    kubectl --context="$CLUSTER_CTX" uncordon "$node" 2>/dev/null || true
    echo "  Cleaned: $node"
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Cleaned practice resources${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show status
echo -e "${CYAN}Cluster status:${NC}"
kubectl --context="$CLUSTER_CTX" get nodes
echo ""
echo -e "${CYAN}Pods in default namespace:${NC}"
kubectl --context="$CLUSTER_CTX" get pods -n default 2>/dev/null || echo "  (none)"
echo ""

echo -e "${GREEN}Ready for next scenario!${NC}"
echo ""
echo -e "${YELLOW}Tip: Add namespaces to USER_NAMESPACES in script if you create new ones${NC}"
