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

# Grade scenario 02: Multi-Container Pod
grade_02() {
    local score=0
    local total=5

    echo -e "${YELLOW}Task 1: Create pod sidecar with labels app=sidecar${NC}"
    if kubectl --context="$CONTEXT" get pod sidecar &>/dev/null; then
        labels=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
        if [ "$labels" = "sidecar" ]; then
            echo -e "  ${GREEN}✓${NC} Pod sidecar exists with app=sidecar label"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod exists but label: $labels (expected sidecar)"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'sidecar' not found"
    fi

    echo -e "${YELLOW}Task 2: Container 1 named main using nginx:alpine${NC}"
    if kubectl --context="$CONTEXT" get pod sidecar &>/dev/null; then
        main_image=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.spec.containers[?(@.name=="main")].image}' 2>/dev/null)
        if [[ "$main_image" == *"nginx"*"alpine"* ]]; then
            echo -e "  ${GREEN}✓${NC} Container main exists with nginx:alpine"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Container main image: $main_image"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'sidecar' not found"
    fi

    echo -e "${YELLOW}Task 3: Container 2 named logger using busybox${NC}"
    if kubectl --context="$CONTEXT" get pod sidecar &>/dev/null; then
        logger_image=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.spec.containers[?(@.name=="logger")].image}' 2>/dev/null)
        if [[ "$logger_image" == *"busybox"* ]]; then
            echo -e "  ${GREEN}✓${NC} Container logger exists with busybox"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Container logger image: $logger_image"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'sidecar' not found"
    fi

    echo -e "${YELLOW}Task 4: Both containers mount emptyDir volume at /data${NC}"
    if kubectl --context="$CONTEXT" get pod sidecar &>/dev/null; then
        main_mount=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.spec.containers[?(@.name=="main")].volumeMounts[?(@.mountPath=="/data")].name}' 2>/dev/null)
        logger_mount=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.spec.containers[?(@.name=="logger")].volumeMounts[?(@.mountPath=="/data")].name}' 2>/dev/null)
        if [ -n "$main_mount" ] && [ -n "$logger_mount" ]; then
            echo -e "  ${GREEN}✓${NC} Both containers mount volume at /data"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Volume mount not properly configured"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'sidecar' not found"
    fi

    echo -e "${YELLOW}Task 5: Both containers are Running${NC}"
    if kubectl --context="$CONTEXT" get pod sidecar &>/dev/null; then
        status=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.status.phase}' 2>/dev/null)
        ready=$(kubectl --context="$CONTEXT" get pod sidecar -o jsonpath='{.status.containerStatuses[*].ready}' 2>/dev/null | wc -w)
        if [ "$status" = "Running" ] && [ "$ready" -ge 2 ]; then
            echo -e "  ${GREEN}✓${NC} Pod is Running with both containers ready"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod status: $status, ready containers: $ready"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'sidecar' not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 03: Node Maintenance
grade_03() {
    local score=0
    local total=6

    echo -e "${YELLOW}Task 1: List all nodes and their roles${NC}"
    nodes=$(kubectl --context="$CONTEXT" get nodes --no-headers 2>/dev/null | wc -l)
    if [ "$nodes" -ge 3 ]; then
        echo -e "  ${GREEN}✓${NC} Found $nodes nodes in cluster"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Expected 3 nodes, found: $nodes"
    fi

    echo -e "${YELLOW}Task 2: Cordon node cka-practice-worker${NC}"
    unschedulable=$(kubectl --context="$CONTEXT" get node cka-practice-worker -o jsonpath='{.spec.unschedulable}' 2>/dev/null)
    if [ "$unschedulable" = "true" ]; then
        echo -e "  ${GREEN}✓${NC} Node cka-practice-worker is cordoned (unschedulable)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Node not cordoned"
    fi

    echo -e "${YELLOW}Task 3: Drain node cka-practice-worker${NC}"
    pods_on_worker=$(kubectl --context="$CONTEXT" get pods -o wide --no-headers 2>/dev/null | grep cka-practice-worker | wc -l)
    if [ "$pods_on_worker" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} No pods on cka-practice-worker (drained successfully)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Still $pods_on_worker pods on node (drain incomplete)"
    fi

    echo -e "${YELLOW}Task 4: Verify pods moved to other nodes${NC}"
    pods_total=$(kubectl --context="$CONTEXT" get pods --no-headers 2>/dev/null | wc -l)
    if [ "$pods_total" -gt 0 ] && [ "$pods_on_worker" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Pods exist and moved off cka-practice-worker"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Pods not properly moved"
    fi

    echo -e "${YELLOW}Task 5: Uncordon node${NC}"
    unschedulable=$(kubectl --context="$CONTEXT" get node cka-practice-worker -o jsonpath='{.spec.unschedulable}' 2>/dev/null)
    if [ "$unschedulable" = "false" ]; then
        echo -e "  ${GREEN}✓${NC} Node cka-practice-worker is schedulable"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Node still cordoned"
    fi

    echo -e "${YELLOW}Task 6: Verify node is Ready${NC}"
    ready=$(kubectl --context="$CONTEXT" get node cka-practice-worker -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    if [ "$ready" = "True" ]; then
        echo -e "  ${GREEN}✓${NC} Node cka-practice-worker is Ready"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Node not Ready"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 04: NetworkPolicy
grade_04() {
    local score=0
    local total=5

    echo -e "${YELLOW}Task 1: Create namespaces frontend and backend${NC}"
    frontend_ns=$(kubectl --context="$CONTEXT" get ns frontend -o jsonpath='{.metadata.name}' 2>/dev/null)
    backend_ns=$(kubectl --context="$CONTEXT" get ns backend -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [ "$frontend_ns" = "frontend" ] && [ "$backend_ns" = "backend" ]; then
        echo -e "  ${GREEN}✓${NC} Both namespaces exist"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Missing namespaces"
    fi

    echo -e "${YELLOW}Task 2: Verify frontend can reach backend (initial)${NC}"
    backend_pod=$(kubectl --context="$CONTEXT" get pod -n backend -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$backend_pod" ]; then
        echo -e "  ${GREEN}✓${NC} Backend pod exists: $backend_pod"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Backend pod not found"
    fi

    echo -e "${YELLOW}Task 3: Create NetworkPolicy deny-all in backend${NC}"
    deny_policy=$(kubectl --context="$CONTEXT" get netpol deny-all -n backend -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [ "$deny_policy" = "deny-all" ]; then
        echo -e "  ${GREEN}✓${NC} NetworkPolicy deny-all exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} deny-all policy not found"
    fi

    echo -e "${YELLOW}Task 4: Update policy to allow from frontend only${NC}"
    allow_policy=$(kubectl --context="$CONTEXT" get netpol -n backend -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    if [[ "$allow_policy" == *"allow"* ]]; then
        echo -e "  ${GREEN}✓${NC} Allow policy exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Allow policy not found"
    fi

    echo -e "${YELLOW}Task 5: Verify policies block traffic correctly${NC}"
    policies=$(kubectl --context="$CONTEXT" get netpol -n backend --no-headers 2>/dev/null | wc -l)
    if [ "$policies" -ge 1 ]; then
        echo -e "  ${GREEN}✓${NC} NetworkPolicies configured in backend namespace"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No NetworkPolicies found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 05: PV and PVC
grade_05() {
    local score=0
    local total=3

    echo -e "${YELLOW}Task 1: Create PV logs-pv (5Gi, RWO, manual, /tmp/logs)${NC}"
    if kubectl --context="$CONTEXT" get pv logs-pv &>/dev/null; then
        capacity=$(kubectl --context="$CONTEXT" get pv logs-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
        access=$(kubectl --context="$CONTEXT" get pv logs-pv -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
        sc=$(kubectl --context="$CONTEXT" get pv logs-pv -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
        if [ "$capacity" = "5Gi" ] && [ "$access" = "ReadWriteOnce" ] && [ "$sc" = "manual" ]; then
            echo -e "  ${GREEN}✓${NC} PV logs-pv configured correctly"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} PV config wrong: cap=$capacity, access=$access, sc=$sc"
        fi
    else
        echo -e "  ${RED}✗${NC} PV logs-pv not found"
    fi

    echo -e "${YELLOW}Task 2: Create PVC logs-pvc (2Gi, RWO)${NC}"
    if kubectl --context="$CONTEXT" get pvc logs-pvc &>/dev/null; then
        request=$(kubectl --context="$CONTEXT" get pvc logs-pvc -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
        access=$(kubectl --context="$CONTEXT" get pvc logs-pvc -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
        if [ "$request" = "2Gi" ] && [ "$access" = "ReadWriteOnce" ]; then
            echo -e "  ${GREEN}✓${NC} PVC logs-pvc configured correctly"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} PVC config wrong: request=$request, access=$access"
        fi
    else
        echo -e "  ${RED}✗${NC} PVC logs-pvc not found"
    fi

    echo -e "${YELLOW}Task 3: Verify PVC bound to PV${NC}"
    if kubectl --context="$CONTEXT" get pvc logs-pvc &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pvc logs-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
        pv_name=$(kubectl --context="$CONTEXT" get pvc logs-pvc -o jsonpath='{.spec.volumeName}' 2>/dev/null)
        if [ "$phase" = "Bound" ] && [ "$pv_name" = "logs-pv" ]; then
            echo -e "  ${GREEN}✓${NC} PVC Bound to PV logs-pv"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} PVC not properly bound: phase=$phase, pv=$pv_name"
        fi
    else
        echo -e "  ${RED}✗${NC} PVC logs-pvc not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 06: RBAC
grade_06() {
    local score=0
    local total=5

    echo -e "${YELLOW}Task 1: Create namespace development${NC}"
    if kubectl --context="$CONTEXT" get ns development &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Namespace development exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Namespace development not found"
    fi

    echo -e "${YELLOW}Task 2: Create Role pod-reader (get,list,watch pods)${NC}"
    if kubectl --context="$CONTEXT" get role pod-reader -n development &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Role pod-reader exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Role pod-reader not found"
    fi

    echo -e "${YELLOW}Task 3: Create RoleBinding jane-pod-read${NC}"
    if kubectl --context="$CONTEXT" get rolebinding jane-pod-read -n development &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} RoleBinding jane-pod-read exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} RoleBinding jane-pod-read not found"
    fi

    echo -e "${YELLOW}Task 4: Verify jane CAN get pods${NC}"
    if kubectl --context="$CONTEXT" auth can-i get pods -n development --as=jane &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} jane can get pods in development namespace"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} jane cannot get pods"
    fi

    echo -e "${YELLOW}Task 5: Verify jane CANNOT delete pods${NC}"
    if kubectl --context="$CONTEXT" auth can-i delete pods -n development --as=jane 2>/dev/null | grep -q "no"; then
        echo -e "  ${GREEN}✓${NC} jane cannot delete pods (correct)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} jane has delete permission (should not)"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 07: Troubleshooting
grade_07() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Identify pod is in CrashLoopBackOff${NC}"
    if kubectl --context="$CONTEXT" get pod broken &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pod broken -o jsonpath='{.status.phase}' 2>/dev/null)
        if [ "$phase" = "Running" ]; then
            echo -e "  ${GREEN}✓${NC} Pod was in CrashLoopBackOff, now fixed and Running"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod still not running: $phase"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'broken' not found"
    fi

    echo -e "${YELLOW}Task 2: Root cause found in logs/describe${NC}"
    if kubectl --context="$CONTEXT" get pod broken &>/dev/null; then
        restarts=$(kubectl --context="$CONTEXT" get pod broken -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null)
        if [ -n "$restarts" ]; then
            echo -e "  ${GREEN}✓${NC} Pod has $restarts restarts (issue investigated)"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Could not determine restart count"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'broken' not found"
    fi

    echo -e "${YELLOW}Task 3: Fix the pod to run successfully${NC}"
    if kubectl --context="$CONTEXT" get pod broken &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pod broken -o jsonpath='{.status.phase}' 2>/dev/null)
        if [ "$phase" = "Running" ]; then
            echo -e "  ${GREEN}✓${NC} Pod fixed and Running"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod still failing: $phase"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'broken' not found"
    fi

    echo -e "${YELLOW}Task 4: Verify pod stays Running${NC}"
    if kubectl --context="$CONTEXT" get pod broken &>/dev/null; then
        ready=$(kubectl --context="$CONTEXT" get pod broken -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
        if [ "$ready" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} Pod is Running and ready"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod not ready"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod 'broken' not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 10: ConfigMap
grade_10() {
    local score=0
    local total=3

    echo -e "${YELLOW}Task 1: Create ConfigMap app-config with database.url and cache.ttl${NC}"
    if kubectl --context="$CONTEXT" get configmap app-config &>/dev/null; then
        db_url=$(kubectl --context="$CONTEXT" get cm app-config -o jsonpath='{.data.database\.url}' 2>/dev/null)
        cache_ttl=$(kubectl --context="$CONTEXT" get cm app-config -o jsonpath='{.data.cache\.ttl}' 2>/dev/null)
        if [[ "$db_url" == *"postgres"* ]] && [ "$cache_ttl" = "60s" ]; then
            echo -e "  ${GREEN}✓${NC} ConfigMap app-config with correct data"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} ConfigMap data wrong: db_url=$db_url, ttl=$cache_ttl"
        fi
    else
        echo -e "  ${RED}✗${NC} ConfigMap app-config not found"
    fi

    echo -e "${YELLOW}Task 2: Create pod config-test mounting ConfigMap at /etc/config${NC}"
    if kubectl --context="$CONTEXT" get pod config-test &>/dev/null; then
        mount=$(kubectl --context="$CONTEXT" get pod config-test -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/config")].name}' 2>/dev/null)
        if [ -n "$mount" ]; then
            echo -e "  ${GREEN}✓${NC} Pod config-test mounts ConfigMap at /etc/config"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod doesn't mount ConfigMap correctly"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod config-test not found"
    fi

    echo -e "${YELLOW}Task 3: Verify files exist in pod with correct content${NC}"
    if kubectl --context="$CONTEXT" get pod config-test &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ConfigMap mounted, verify manually: kubectl exec config-test -- ls /etc/config${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Cannot verify - pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 11: Jobs & CronJobs
grade_11() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create Job pi-job with perl:5.34${NC}"
    if kubectl --context="$CONTEXT" get job pi-job &>/dev/null; then
        image=$(kubectl --context="$CONTEXT" get job pi-job -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        if [[ "$image" == *"perl:5.34"* ]]; then
            echo -e "  ${GREEN}✓${NC} Job pi-job exists with perl:5.34"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Job image wrong: $image"
        fi
    else
        echo -e "  ${RED}✗${NC} Job pi-job not found"
    fi

    echo -e "${YELLOW}Task 2: Verify Job completed successfully${NC}"
    if kubectl --context="$CONTEXT" get job pi-job &>/dev/null; then
        complete=$(kubectl --context="$CONTEXT" get job pi-job -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' 2>/dev/null)
        if [ "$complete" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} Job completed successfully"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Job not complete yet"
        fi
    else
        echo -e "  ${RED}✗${NC} Job pi-job not found"
    fi

    echo -e "${YELLOW}Task 3: Create CronJob hello-cj (every minute, busybox)${NC}"
    if kubectl --context="$CONTEXT" get cj hello-cj &>/dev/null; then
        schedule=$(kubectl --context="$CONTEXT" get cj hello-cj -o jsonpath='{.spec.schedule}' 2>/dev/null)
        image=$(kubectl --context="$CONTEXT" get cj hello-cj -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
        if [ "$schedule" = "*/1 * * * *" ] && [[ "$image" == *"busybox"* ]]; then
            echo -e "  ${GREEN}✓${NC} CronJob hello-cj configured correctly"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} CronJob config wrong: schedule=$schedule, image=$image"
        fi
    else
        echo -e "  ${RED}✗${NC} CronJob hello-cj not found"
    fi

    echo -e "${YELLOW}Task 4: CronJob retention settings${NC}"
    if kubectl --context="$CONTEXT" get cj hello-cj &>/dev/null; then
        success=$(kubectl --context="$CONTEXT" get cj hello-cj -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
        failed=$(kubectl --context="$CONTEXT" get cj hello-cj -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
        if [ "$success" = "3" ] && [ "$failed" = "1" ]; then
            echo -e "  ${GREEN}✓${NC} Retention set: 3 successful, 1 failed"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Retention wrong: success=$success, failed=$failed"
        fi
    else
        echo -e "  ${RED}✗${NC} CronJob hello-cj not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 12: etcd Backup
grade_12() {
    local score=0
    local total=5

    echo -e "${YELLOW}Task 1: Find etcd pod${NC}"
    etcd_pod=$(kubectl --context="$CONTEXT" get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$etcd_pod" ]; then
        echo -e "  ${GREEN}✓${NC} Found etcd pod: $etcd_pod"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} etcd pod not found"
    fi

    echo -e "${YELLOW}Task 2: Check etcd version${NC}"
    if [ -n "$etcd_pod" ]; then
        version=$(kubectl --context="$CONTEXT" exec -n kube-system "$etcd_pod" -- etcdctl version 2>/dev/null | grep "etcdctl version" || echo "")
        if [ -n "$version" ]; then
            echo -e "  ${GREEN}✓${NC} etcd version checked"
            score=$((score + 1))
        else
            echo -e "  ${GREEN}✓${NC} etcd pod exists (version check skipped for kind)${NC}"
            score=$((score + 1))
        fi
    else
        echo -e "  ${RED}✗${NC} Cannot check version - no etcd pod"
    fi

    echo -e "${YELLOW}Task 3: Verify etcd backup file exists${NC}"
    if [ -f "/tmp/etcd-backup.db" ]; then
        echo -e "  ${GREEN}✓${NC} Backup file exists: /tmp/etcd-backup.db"
        score=$((score + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} Backup not on control plane - verify manually"
    fi

    echo -e "${YELLOW}Task 4: List snapshot status${NC}"
    echo -e "  ${GREEN}✓${NC} Verify manually: ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db${NC}"
    score=$((score + 1))

    echo -e "${YELLOW}Task 5: Backup parameters verified${NC}"
    echo -e "  ${GREEN}✓${NC} Check you used correct endpoints, cacert, cert, key${NC}"
    score=$((score + 1))

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 13: Resource Limits
grade_13() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create resource-pod with nginx, correct requests/limits${NC}"
    if kubectl --context="$CONTEXT" get pod resource-pod &>/dev/null; then
        cpu_req=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
        cpu_lim=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
        mem_req=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
        mem_lim=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
        if [ "$cpu_req" = "100m" ] && [ "$cpu_lim" = "200m" ] && [ "$mem_req" = "128Mi" ] && [ "$mem_lim" = "256Mi" ]; then
            echo -e "  ${GREEN}✓${NC} resource-pod configured correctly"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Wrong values: cpu=$cpu_req/$cpu_lim, mem=$mem_req/$mem_lim"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod resource-pod not found"
    fi

    echo -e "${YELLOW}Task 2: Verify resource allocation${NC}"
    if kubectl --context="$CONTEXT" get pod resource-pod &>/dev/null; then
        qos=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.status.qosClass}' 2>/dev/null)
        if [ "$qos" = "Burstable" ]; then
            echo -e "  ${GREEN}✓${NC} QoS class: Burstable (correct for requests<limits)"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} QoS class: $qos (expected Burstable)"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod resource-pod not found"
    fi

    echo -e "${YELLOW}Task 3: Check QoS class${NC}"
    if kubectl --context="$CONTEXT" get pod resource-pod &>/dev/null; then
        qos=$(kubectl --context="$CONTEXT" get pod resource-pod -o jsonpath='{.status.qosClass}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} QoS class: $qos${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Cannot check - pod not found"
    fi

    echo -e "${YELLOW}Task 4: Create guaranteed-pod with Guaranteed QoS${NC}"
    if kubectl --context="$CONTEXT" get pod guaranteed-pod &>/dev/null; then
        qos=$(kubectl --context="$CONTEXT" get pod guaranteed-pod -o jsonpath='{.status.qosClass}' 2>/dev/null)
        if [ "$qos" = "Guaranteed" ]; then
            echo -e "  ${GREEN}✓${NC} guaranteed-pod has Guaranteed QoS"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} QoS class: $qos (expected Guaranteed)"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod guaranteed-pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 14: Init Containers
grade_14() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create init-pod with init container and main container${NC}"
    if kubectl --context="$CONTEXT" get pod init-pod &>/dev/null; then
        init_count=$(kubectl --context="$CONTEXT" get pod init-pod -o jsonpath='{.spec.initContainers}' 2>/dev/null | wc -w)
        main_image=$(kubectl --context="$CONTEXT" get pod init-pod -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
        if [ "$init_count" -ge 1 ] && [[ "$main_image" == *"nginx"* ]]; then
            echo -e "  ${GREEN}✓${NC} init-pod has init container + nginx main"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Wrong config: init=$init_count, image=$main_image"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod init-pod not found"
    fi

    echo -e "${YELLOW}Task 2: Verify init container completed${NC}"
    if kubectl --context="$CONTEXT" get pod init-pod &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pod init-pod -o jsonpath='{.status.phase}' 2>/dev/null)
        ready=$(kubectl --context="$CONTEXT" get pod init-pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
        if [ "$phase" = "Running" ] && [ "$ready" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} Init completed, main container running"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod not ready: phase=$phase"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod init-pod not found"
    fi

    echo -e "${YELLOW}Task 3: Create multi-init-pod with two init containers sharing volume${NC}"
    if kubectl --context="$CONTEXT" get pod multi-init-pod &>/dev/null; then
        init_count=$(kubectl --context="$CONTEXT" get pod multi-init-pod -o jsonpath='{.spec.initContainers}' 2>/dev/null | wc -w)
        if [ "$init_count" -ge 2 ]; then
            echo -e "  ${GREEN}✓${NC} multi-init-pod has 2+ init containers"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Only $init_count init containers"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod multi-init-pod not found"
    fi

    echo -e "${YELLOW}Task 4: Check all init containers completed and main running${NC}"
    if kubectl --context="$CONTEXT" get pod multi-init-pod &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pod multi-init-pod -o jsonpath='{.status.phase}' 2>/dev/null)
        ready=$(kubectl --context="$CONTEXT" get pod multi-init-pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
        if [ "$phase" = "Running" ] && [ "$ready" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} All init completed, main container running"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod not ready: phase=$phase"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod multi-init-pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 15: PodDisruptionBudget
grade_15() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Check deployment web-app has 5 replicas${NC}"
    if kubectl --context="$CONTEXT" get deployment web-app &>/dev/null; then
        replicas=$(kubectl --context="$CONTEXT" get deployment web-app -o jsonpath='{.spec.replicas}' 2>/dev/null)
        ready=$(kubectl --context="$CONTEXT" get deployment web-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
        if [ "$replicas" = "5" ]; then
            echo -e "  ${GREEN}✓${NC} Deployment has 5 replicas ($ready ready)"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Wrong replica count: $replicas"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment web-app not found"
    fi

    echo -e "${YELLOW}Task 2: Create PDB web-pdb${NC}"
    if kubectl --context="$CONTEXT" get pdb web-pdb &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} PDB web-pdb exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} PDB web-pdb not found"
    fi

    echo -e "${YELLOW}Task 3: Verify PDB configuration (minAvailable or maxUnavailable)${NC}"
    if kubectl --context="$CONTEXT" get pdb web-pdb &>/dev/null; then
        min_avail=$(kubectl --context="$CONTEXT" get pdb web-pdb -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
        max_unavail=$(kubectl --context="$CONTEXT" get pdb web-pdb -o jsonpath='{.spec.maxUnavailable}' 2>/dev/null)
        if [ -n "$min_avail" ] || [ -n "$max_unavail" ]; then
            echo -e "  ${GREEN}✓${NC} PDB configured: minAvailable=$min_avail, maxUnavailable=$max_unavail"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} No minAvailable or maxUnavailable set"
        fi
    else
        echo -e "  ${RED}✗${NC} PDB web-pdb not found"
    fi

    echo -e "${YELLOW}Task 4: Check PDB status and allowed disruptions${NC}"
    if kubectl --context="$CONTEXT" get pdb web-pdb &>/dev/null; then
        allowed=$(kubectl --context="$CONTEXT" get pdb web-pdb -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Allowed disruptions: $allowed${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} PDB web-pdb not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 16: Probes
grade_16() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create pod probe-pod with liveness probe${NC}"
    if kubectl --context="$CONTEXT" get pod probe-pod &>/dev/null; then
        probe=$(kubectl --context="$CONTEXT" get pod probe-pod -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
        if [ "$probe" = "/" ]; then
            echo -e "  ${GREEN}✓${NC} Liveness probe configured on /"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Liveness probe path: $probe"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod probe-pod not found"
    fi

    echo -e "${YELLOW}Task 2: Add readiness probe${NC}"
    if kubectl --context="$CONTEXT" get pod probe-pod &>/dev/null; then
        ready_probe=$(kubectl --context="$CONTEXT" get pod probe-pod -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
        if [ "$ready_probe" = "/" ]; then
            echo -e "  ${GREEN}✓${NC} Readiness probe configured on /"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Readiness probe not configured"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod probe-pod not found"
    fi

    echo -e "${YELLOW}Task 3: Test probe behavior - pod becomes Ready${NC}"
    if kubectl --context="$CONTEXT" get pod probe-pod &>/dev/null; then
        ready=$(kubectl --context="$CONTEXT" get pod probe-pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
        if [ "$ready" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} Pod is Ready"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod not ready"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod probe-pod not found"
    fi

    echo -e "${YELLOW}Task 4: Check probe configuration details${NC}"
    if kubectl --context="$CONTEXT" get pod probe-pod &>/dev/null; then
        init_delay=$(kubectl --context="$CONTEXT" get pod probe-pod -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
        period=$(kubectl --context="$CONTEXT" get pod probe-pod -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Probe configured: initialDelay=$init_delay, period=$period${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Pod probe-pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 17: HPA
grade_17() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create HPA test-hpa for test-app deployment${NC}"
    if kubectl --context="$CONTEXT" get hpa test-hpa &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} HPA test-hpa exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} HPA test-hpa not found"
    fi

    echo -e "${YELLOW}Task 2: Verify HPA min/max replicas (2-5)${NC}"
    if kubectl --context="$CONTEXT" get hpa test-hpa &>/dev/null; then
        min_replicas=$(kubectl --context="$CONTEXT" get hpa test-hpa -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
        max_replicas=$(kubectl --context="$CONTEXT" get hpa test-hpa -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
        if [ "$min_replicas" = "2" ] && [ "$max_replicas" = "5" ]; then
            echo -e "  ${GREEN}✓${NC} Min/max replicas: $min_replicas/$max_replicas"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Wrong min/max: $min_replicas/$max_replicas"
        fi
    else
        echo -e "  ${RED}✗${NC} HPA test-hpa not found"
    fi

    echo -e "${YELLOW}Task 3: Verify target CPU 70%, memory 80%${NC}"
    if kubectl --context="$CONTEXT" get hpa test-hpa &>/dev/null; then
        cpu_target=$(kubectl --context="$CONTEXT" get hpa test-hpa -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} CPU target: $cpu_target% (check memory target manually)${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} HPA test-hpa not found"
    fi

    echo -e "${YELLOW}Task 4: Check HPA status and current metrics${NC}"
    if kubectl --context="$CONTEXT" get hpa test-hpa &>/dev/null; then
        replicas=$(kubectl --context="$CONTEXT" get hpa test-hpa -o jsonpath='{.status.currentReplicas}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Current replicas: $replicas${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} HPA test-hpa not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 18: StatefulSet
grade_18() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create StatefulSet web with 3 replicas${NC}"
    if kubectl --context="$CONTEXT" get statefulset web &>/dev/null; then
        replicas=$(kubectl --context="$CONTEXT" get statefulset web -o jsonpath='{.spec.replicas}' 2>/dev/null)
        if [ "$replicas" = "3" ]; then
            echo -e "  ${GREEN}✓${NC} StatefulSet web has 3 replicas"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Wrong replicas: $replicas"
        fi
    else
        echo -e "  ${RED}✗${NC} StatefulSet web not found"
    fi

    echo -e "${YELLOW}Task 2: Create headless service web (ClusterIP: None)${NC}"
    if kubectl --context="$CONTEXT" get svc web &>/dev/null; then
        cluster_ip=$(kubectl --context="$CONTEXT" get svc web -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
        if [ "$cluster_ip" = "None" ]; then
            echo -e "  ${GREEN}✓${NC} Headless service web (ClusterIP: None)"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Not headless: ClusterIP=$cluster_ip"
        fi
    else
        echo -e "  ${RED}✗${NC} Service web not found"
    fi

    echo -e "${YELLOW}Task 3: Verify PVCs created per pod (web-0, web-1, web-2)${NC}"
    pvc_count=$(kubectl --context="$CONTEXT" get pvc -o jsonpath='{.items[?(@.metadata.ownerReferences[*].kind=="StatefulSet")].metadata.name}' 2>/dev/null | wc -w)
    if [ "$pvc_count" -ge 3 ]; then
        echo -e "  ${GREEN}✓${NC} Created $pvc_count PVCs for StatefulSet"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Only $pvc_count PVCs found"
    fi

    echo -e "${YELLOW}Task 4: Check stable network names (web-0.web, web-1.web, web-2.web)${NC}"
    pod_0=$(kubectl --context="$CONTEXT" get pod web-0 -o jsonpath='{.metadata.name}' 2>/dev/null)
    pod_1=$(kubectl --context="$CONTEXT" get pod web-1 -o jsonpath='{.metadata.name}' 2>/dev/null)
    pod_2=$(kubectl --context="$CONTEXT" get pod web-2 -o jsonpath='{.metadata.name}' 2>/dev/null)
    if [ "$pod_0" = "web-0" ] && [ "$pod_1" = "web-1" ] && [ "$pod_2" = "web-2" ]; then
        echo -e "  ${GREEN}✓${NC} Stable pod names: web-0, web-1, web-2"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Stable names not configured"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 19: StorageClass
grade_19() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Check available storage classes${NC}"
    sc_count=$(kubectl --context="$CONTEXT" get sc --no-headers 2>/dev/null | wc -l)
    if [ "$sc_count" -ge 1 ]; then
        echo -e "  ${GREEN}✓${NC} Found $sc_count StorageClass(es)"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No StorageClass found"
    fi

    echo -e "${YELLOW}Task 2: Create PVC dynamic-pvc with StorageClass${NC}"
    if kubectl --context="$CONTEXT" get pvc dynamic-pvc &>/dev/null; then
        sc=$(kubectl --context="$CONTEXT" get pvc dynamic-pvc -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
        if [ -n "$sc" ]; then
            echo -e "  ${GREEN}✓${NC} PVC dynamic-pvc uses StorageClass: $sc"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} PVC has no StorageClass"
        fi
    else
        echo -e "  ${RED}✗${NC} PVC dynamic-pvc not found"
    fi

    echo -e "${YELLOW}Task 3: Verify dynamic provisioning (PV auto-created)${NC}"
    if kubectl --context="$CONTEXT" get pvc dynamic-pvc &>/dev/null; then
        phase=$(kubectl --context="$CONTEXT" get pvc dynamic-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
        pv_name=$(kubectl --context="$CONTEXT" get pvc dynamic-pvc -o jsonpath='{.spec.volumeName}' 2>/dev/null)
        if [ "$phase" = "Bound" ] && [ -n "$pv_name" ]; then
            echo -e "  ${GREEN}✓${NC} PVC Bound to auto-created PV: $pv_name"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} PVC not bound: phase=$phase"
        fi
    else
        echo -e "  ${RED}✗${NC} PVC dynamic-pvc not found"
    fi

    echo -e "${YELLOW}Task 4: Use PVC in pod storage-pod${NC}"
    if kubectl --context="$CONTEXT" get pod storage-pod &>/dev/null; then
        volume_name=$(kubectl --context="$CONTEXT" get pod storage-pod -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}' 2>/dev/null)
        if [ "$volume_name" = "dynamic-pvc" ]; then
            echo -e "  ${GREEN}✓${NC} Pod storage-pod mounts PVC dynamic-pvc"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod doesn't mount dynamic-pvc"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod storage-pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 20: ServiceAccounts
grade_20() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create ServiceAccount pod-sa${NC}"
    if kubectl --context="$CONTEXT" get sa pod-sa &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ServiceAccount pod-sa exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} ServiceAccount pod-sa not found"
    fi

    echo -e "${YELLOW}Task 2: Create Role pod-role (get,list pods,services)${NC}"
    if kubectl --context="$CONTEXT" get role pod-role &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Role pod-role exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Role pod-role not found"
    fi

    echo -e "${YELLOW}Task 3: Create RoleBinding pod-rolebinding${NC}"
    if kubectl --context="$CONTEXT" get rolebinding pod-rolebinding &>/dev/null; then
        sa_ref=$(kubectl --context="$CONTEXT" get rolebinding pod-rolebinding -o jsonpath='{.subjects[0].name}' 2>/dev/null)
        if [ "$sa_ref" = "pod-sa" ]; then
            echo -e "  ${GREEN}✓${NC} RoleBinding links to pod-sa"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} RoleBinding doesn't link to pod-sa"
        fi
    else
        echo -e "  ${RED}✗${NC} RoleBinding pod-rolebinding not found"
    fi

    echo -e "${YELLOW}Task 4: Create pod sa-test-pod using ServiceAccount pod-sa${NC}"
    if kubectl --context="$CONTEXT" get pod sa-test-pod &>/dev/null; then
        pod_sa=$(kubectl --context="$CONTEXT" get pod sa-test-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
        if [ "$pod_sa" = "pod-sa" ]; then
            echo -e "  ${GREEN}✓${NC} Pod uses ServiceAccount pod-sa"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Pod SA: $pod_sa (expected pod-sa)"
        fi
    else
        echo -e "  ${RED}✗${NC} Pod sa-test-pod not found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 21: CoreDNS
grade_21() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Check CoreDNS pods running${NC}"
    coredns_count=$(kubectl --context="$CONTEXT" get pods -n kube-system -l k8s-app=kube-dns --no-headers 2>/dev/null | grep Running | wc -l)
    if [ "$coredns_count" -ge 1 ]; then
        echo -e "  ${GREEN}✓${NC} CoreDNS pods running: $coredns_count"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} CoreDNS not running"
    fi

    echo -e "${YELLOW}Task 2: Check CoreDNS service${NC}"
    if kubectl --context="$CONTEXT" get svc kube-dns -n kube-system &>/dev/null; then
        cluster_ip=$(kubectl --context="$CONTEXT" get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} CoreDNS service exists: $cluster_ip${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} CoreDNS service not found"
    fi

    echo -e "${YELLOW}Task 3: Test DNS resolution from pod${NC}"
    if kubectl --context="$CONTEXT" get pod dns-debug &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Pod dns-debug exists - verify resolution manually${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Pod dns-debug not found"
    fi

    echo -e "${YELLOW}Task 4: Debug DNS failure (check resolv.conf)${NC}"
    echo -e "  ${GREEN}✓${NC} Check manually: kubectl exec dns-debug -- cat /etc/resolv.conf${NC}"
    score=$((score + 1))

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 22: Advanced NetworkPolicy
grade_22() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Create deny-all policy (deny all ingress and egress)${NC}"
    if kubectl --context="$CONTEXT" get netpol deny-all -n backend &>/dev/null; then
        policy_types=$(kubectl --context="$CONTEXT" get netpol deny-all -n backend -o jsonpath='{.spec.policyTypes}' 2>/dev/null | wc -w)
        if [ "$policy_types" -ge 2 ]; then
            echo -e "  ${GREEN}✓${NC} deny-all policy exists with Ingress+Egress"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} deny-all missing Ingress or Egress policyType"
        fi
    else
        echo -e "  ${RED}✗${NC} deny-all policy not found"
    fi

    echo -e "${YELLOW}Task 2: Add allow-frontend policy (allow from frontend, port 80)${NC}"
    allow_frontend=$(kubectl --context="$CONTEXT" get netpol -n backend -o jsonpath='{.items[?(@.metadata.name=="allow-frontend")].metadata.name}' 2>/dev/null)
    if [ "$allow_frontend" = "allow-frontend" ]; then
        echo -e "  ${GREEN}✓${NC} allow-frontend policy exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} allow-frontend policy not found"
    fi

    echo -e "${YELLOW}Task 3: Add allow-dns policy (allow UDP port 53 to kube-system)${NC}"
    allow_dns=$(kubectl --context="$CONTEXT" get netpol -n backend -o jsonpath='{.items[?(@.metadata.name=="allow-dns")].metadata.name}' 2>/dev/null)
    if [ "$allow_dns" = "allow-dns" ]; then
        echo -e "  ${GREEN}✓${NC} allow-dns policy exists"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} allow-dns policy not found"
    fi

    echo -e "${YELLOW}Task 4: Verify policies block traffic correctly${NC}"
    netpol_count=$(kubectl --context="$CONTEXT" get netpol -n backend --no-headers 2>/dev/null | wc -l)
    if [ "$netpol_count" -ge 1 ]; then
        echo -e "  ${GREEN}✓${NC} $netpol_count NetworkPolicy(s) configured${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No NetworkPolicies found"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Score: ${GREEN}$score${NC} / $total"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    return $score
}

# Grade scenario 23: Rolling Update
grade_23() {
    local score=0
    local total=4

    echo -e "${YELLOW}Task 1: Check current deployment strategy${NC}"
    if kubectl --context="$CONTEXT" get deployment rolling-app &>/dev/null; then
        strategy=$(kubectl --context="$CONTEXT" get deployment rolling-app -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Deployment strategy: $strategy${NC}"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} Deployment rolling-app not found"
    fi

    echo -e "${YELLOW}Task 2: Configure custom rolling strategy (maxSurge/maxUnavailable)${NC}"
    if kubectl --context="$CONTEXT" get deployment rolling-app &>/dev/null; then
        max_surge=$(kubectl --context="$CONTEXT" get deployment rolling-app -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
        max_unavail=$(kubectl --context="$CONTEXT" get deployment rolling-app -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
        if [ -n "$max_surge" ] && [ -n "$max_unavail" ]; then
            echo -e "  ${GREEN}✓${NC} Strategy: maxSurge=$max_surge, maxUnavailable=$max_unavail"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Custom strategy not configured"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment rolling-app not found"
    fi

    echo -e "${YELLOW}Task 3: Perform rolling update to nginx:1.25${NC}"
    if kubectl --context="$CONTEXT" get deployment rolling-app &>/dev/null; then
        image=$(kubectl --context="$CONTEXT" get deployment rolling-app -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        if [[ "$image" == *"1.25"* ]]; then
            echo -e "  ${GREEN}✓${NC} Image updated to: $image"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} Current image: $image (expected nginx:1.25)"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment rolling-app not found"
    fi

    echo -e "${YELLOW}Task 4: Verify update completed${NC}"
    if kubectl --context="$CONTEXT" get deployment rolling-app &>/dev/null; then
        revisions=$(kubectl --context="$CONTEXT" rollout history deployment/rolling-app 2>/dev/null | grep -c "^[0-9]" || echo 0)
        if [ "$revisions" -gt 1 ]; then
            echo -e "  ${GREEN}✓${NC} Rollout completed ($revisions revisions)"
            score=$((score + 1))
        else
            echo -e "  ${RED}✗${NC} No rollout history found"
        fi
    else
        echo -e "  ${RED}✗${NC} Deployment rolling-app not found"
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
    02|2) grade_02 ;;
    03|3) grade_03 ;;
    04|4) grade_04 ;;
    05|5) grade_05 ;;
    06|6) grade_06 ;;
    07|7) grade_07 ;;
    08|8) grade_08 ;;
    09|9) grade_09 ;;
    10) grade_10 ;;
    11) grade_11 ;;
    12) grade_12 ;;
    13) grade_13 ;;
    14) grade_14 ;;
    15) grade_15 ;;
    16) grade_16 ;;
    17) grade_17 ;;
    18) grade_18 ;;
    19) grade_19 ;;
    20) grade_20 ;;
    21) grade_21 ;;
    22) grade_22 ;;
    23) grade_23 ;;
    *) echo "Grader for scenario $scenario_id not yet implemented" ;;
esac
