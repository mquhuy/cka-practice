#!/bin/bash
# CKA Exam Grader - Check cluster state against requirements
# Usage: ./grade.sh [scenario-id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
CONTEXT="kind-cka-practice"

scenario_id="$1"

if [ -z "$scenario_id" ]; then
    echo "Usage: ./grade.sh [scenario-id]"
    echo "Example: ./grade.sh 01"
    exit 1
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Grading Scenario $scenario_id${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Grading current cluster state..."
echo ""

# Grade scenario 01
grade_01() {
    local score=0
    local total=6

    echo -e "${YELLOW}Task 1: Create deployment web (nginx:1.27, 3 replicas)${NC}"
    if kubectl --context="$CONTEXT" get deployment web &>/dev/null; then
        replicas=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.replicas}')
        image=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}')
        if [ "$replicas" -ge 3 ] && [[ "$image" == *"nginx:1.27"* ]]; then
            echo -e "  ${GREEN}✓${NC} Deployment exists with correct image and $replicas replicas"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Deployment exists but: replicas=$replicas, image=$image"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment 'web' not found"
    fi

    echo -e "${YELLOW}Task 2: Expose NodePort service web-svc on port 30080${NC}"
    if kubectl --context="$CONTEXT" get svc web-svc &>/dev/null; then
        nodeport=$(kubectl --context="$CONTEXT" get svc web-svc -o jsonpath='{.spec.ports[0].nodePort}')
        targetport=$(kubectl --context="$CONTEXT" get svc web-svc -o jsonpath='{.spec.ports[0].targetPort}')
        if [ "$nodeport" = "30080" ]; then
            if [ "$targetport" = "80" ] || [ "$targetport" = "80" ]; then
                echo -e "  ${GREEN}✓${NC} Service correct: NodePort=$nodeport, targetPort=$targetport"
                score=$((score + 1))
            else
                echo -e "  ${YELLOW}⚠${NC} NodePort correct but targetPort=$targetport (should be 80)"
                score=$((score + 1))
            fi
        else
            echo -e "  ${RED}✗${NC} Service exists but NodePort=$nodeport (expected 30080)"
        fi
    else
        echo -e "  ${RED}✗${NC} Service 'web-svc' not found"
    fi

    echo -e "${YELLOW}Task 3: Scale to 5 replicas${NC}"
    replicas=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.replicas}' 2>/dev/null)
    if [ "$replicas" = "5" ]; then
        echo -e "  ${GREEN}✓${NC} Scaled to 5 replicas"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Current replicas: $replicas (expected 5)"
    fi

    echo -e "${YELLOW}Task 4: Update image to nginx:1.28${NC}"
    current_image=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    revisions=$(kubectl --context="$CONTEXT" rollout history deployment/web 2>/dev/null | grep -c "^[0-9]" || echo 0)
    if [ "$revisions" -gt 1 ]; then
        echo -e "  ${GREEN}✓${NC} Image updated ($revisions revisions in history)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No image update detected (only 1 revision)"
    fi

    echo -e "${YELLOW}Task 5: Rollout completed${NC}"
    # Check rollout status indirectly - if updated and pods ready
    ready_replicas=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    desired_replicas=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.replicas}' 2>/dev/null)
    if [ "$ready_replicas" = "$desired_replicas" ] && [ "$ready_replicas" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} Rollout completed ($ready_replicas/$desired_replicas ready)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Rollout incomplete ($ready_replicas/$desired_replicas ready)"
    fi

    echo -e "${YELLOW}Task 6: Rollback${NC}"
    # Check if rollback happened by examining revisions
    if [ "$revisions" -gt 1 ]; then
        echo -e "  ${GREEN}✓${NC} Rollback performed (current: $current_image)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No rollback detected"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    return $score
}

# Grade scenario 08
grade_08() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create deployment web (nginx:alpine, 2 replicas)${NC}"
    if kubectl --context="$CONTEXT" get deployment web &>/dev/null; then
        replicas=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.replicas}')
        image=$(kubectl --context="$CONTEXT" get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}')
        if [ "$replicas" -ge 2 ] && [[ "$image" == *"nginx"*"alpine"* ]]; then
            echo -e "  ${GREEN}✓${NC} Deployment exists with correct image and $replicas replicas"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Deployment exists but: replicas=$replicas, image=$image"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment 'web' not found"
    fi

    echo -e "${YELLOW}Task 2: Create ClusterIP service web-svc on port 80${NC}"
    if kubectl --context="$CONTEXT" get svc web-svc &>/dev/null; then
        svc_type=$(kubectl --context="$CONTEXT" get svc web-svc -o jsonpath='{.spec.type}')
        svc_port=$(kubectl --context="$CONTEXT" get svc web-svc -o jsonpath='{.spec.ports[0].port}')
        if [ "$svc_type" = "ClusterIP" ] && [ "$svc_port" = "80" ]; then
            echo -e "  ${GREEN}✓${NC} Service correct: type=$svc_type, port=$svc_port"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Service exists but: type=$svc_type, port=$svc_port"
        fi
    else
        echo -e "  ${RED}✗${NC} Service 'web-svc' not found"
    fi

    echo -e "${YELLOW}Task 3: Create Ingress web-ing${NC}"
    if kubectl --context="$CONTEXT" get ingress web-ing &>/dev/null; then
        host=$(kubectl --context="$CONTEXT" get ingress web-ing -o jsonpath='{.spec.rules[0].host}')
        if [ "$host" = "web.example.com" ]; then
            echo -e "  ${GREEN}✓${NC} Ingress exists with host: $host"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Ingress exists but host: $host (expected web.example.com)"
        fi
    else
        echo -e "  ${RED}✗${NC} Ingress 'web-ing' not found"
    fi

    echo -e "${YELLOW}Task 4: IngressClassName is nginx${NC}"
    if kubectl --context="$CONTEXT" get ingress web-ing &>/dev/null; then
        ingress_class=$(kubectl --context="$CONTEXT" get ingress web-ing -o jsonpath='{.spec.ingressClassName}')
        if [ "$ingress_class" = "nginx" ]; then
            echo -e "  ${GREEN}✓${NC} IngressClassName: $ingress_class"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} IngressClassName: $ingress_class (expected nginx)"
        fi
    else
        echo -e "  ${RED}✗${NC} Ingress 'web-ing' not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    return $score
}

# Grade scenario 09
grade_09() {
    local score=0
    local total=5

    echo -e "${YELLOW}Task 1: Label cka-practice-worker as env=prod${NC}"
    worker1_label=$(kubectl --context="$CONTEXT" get node cka-practice-worker -o jsonpath='{.metadata.labels.env}' 2>/dev/null)
    if [ "$worker1_label" = "prod" ]; then
        echo -e "  ${GREEN}✓${NC} cka-practice-worker labeled env=prod"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} cka-practice-worker label: $worker1_label (expected prod)"
    fi

    echo -e "${YELLOW}Task 2: Label cka-practice-worker2 as env=dev${NC}"
    worker2_label=$(kubectl --context="$CONTEXT" get node cka-practice-worker2 -o jsonpath='{.metadata.labels.env}' 2>/dev/null)
    if [ "$worker2_label" = "dev" ]; then
        echo -e "  ${GREEN}✓${NC} cka-practice-worker2 labeled env=dev"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} cka-practice-worker2 label: $worker2_label (expected dev)"
    fi

    echo -e "${YELLOW}Task 3: Create pod prod-app with nodeSelector env=prod${NC}"
    if kubectl --context="$CONTEXT" get pod prod-app &>/dev/null; then
        node_selector=$(kubectl --context="$CONTEXT" get pod prod-app -o jsonpath='{.spec.nodeSelector.env}' 2>/dev/null)
        pod_node=$(kubectl --context="$CONTEXT" get pod prod-app -o jsonpath='{.spec.nodeName}' 2>/dev/null)
        if [ "$node_selector" = "prod" ] && [ "$pod_node" = "cka-practice-worker" ]; then
            echo -e "  ${GREEN}✓${NC} prod-app uses nodeSelector env=prod, running on cka-practice-worker"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} nodeSelector: $node_selector, running on: $pod_node"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'prod-app' not found"
    fi

    echo -e "${YELLOW}Task 4: Taint prod node with dedicated=prod:NoSchedule${NC}"
    taints=$(kubectl --context="$CONTEXT" get node cka-practice-worker -o jsonpath='{.spec.taints}' 2>/dev/null)
    if echo "$taints" | grep -q "dedicated.*prod.*NoSchedule"; then
        echo -e "  ${GREEN}✓${NC} cka-practice-worker tainted with dedicated=prod:NoSchedule"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Taint not found or incorrect"
    fi

    echo -e "${YELLOW}Task 5: Create pod with toleration for dedicated=prod:NoSchedule${NC}"
    # Check for any pod with toleration (name varies)
    tolerant_pod=$(kubectl --context="$CONTEXT" get pods -o jsonpath='{.items[?(@.spec.tolerations[*].key=="dedicated")].metadata.name}' 2>/dev/null | head -1)
    if [ -n "$tolerant_pod" ]; then
        toleration=$(kubectl --context="$CONTEXT" get pod "$tolerant_pod" -o jsonpath='{.spec.tolerations[0].key}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Pod '$tolerant_pod' has toleration for key: $toleration"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No pod found with toleration for 'dedicated' taint"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    return $score
}

# Route to appropriate grader
case "$scenario_id" in
    01|1) grade_01 ;;
    08|8) grade_08 ;;
    09|9) grade_09 ;;
    *) echo "Grader for scenario $scenario_id not yet implemented" ;;
esac
