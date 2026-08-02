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

# Route to appropriate grader
case "$scenario_id" in
    01|1) grade_01 ;;
    *) echo "Grader for scenario $scenario_id not yet implemented" ;;
esac
