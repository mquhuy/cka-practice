#!/bin/bash
# CKA Exam Practice - Local Killercoda-like interface
# Usage: ./exam-practice.sh [scenario-id]

CLUSTER_CTX="kind-cka-practice"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR"
SCENARIOS_DIR="$BASE_DIR/scenarios"
SUBMISSIONS_DIR="$BASE_DIR/submissions"
mkdir -p "$SUBMISSIONS_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ASCII Art
print_header() {
    clear
    echo -e "${CYAN}"
    cat <<'EOF'
┌─────────────────────────────────────────────────────────────┐
│                    CKA EXAM PRACTICE                        │
│              Local Killercoda-like Interface                 │
└─────────────────────────────────────────────────────────────┘
EOF
    echo -e "${NC}"
}

# Check cluster
check_cluster() {
    if ! kubectl --context="$CLUSTER_CTX" get nodes &>/dev/null; then
        echo -e "${RED}✗ Cluster not ready!${NC}"
        echo "Start cluster: kind create cluster --config=kind-cluster.yaml --name=cka-practice"
        exit 1
    fi
    echo -e "${GREEN}✓ Cluster ready${NC}"
    kubectl --context="$CLUSTER_CTX" get nodes
}

# Get scenario info by ID
get_scenario() {
    case "$1" in
        01|1) echo "deployment-basic|Deployments|5|Create deployment, scale, update, rollback" ;;
        02|2) echo "multi-container|Multi-Container Pods|4|Pod with 2 containers, shared volume" ;;
        03|3) echo "node-maintenance|Node Maintenance|5|Cordon, drain, uncordon nodes" ;;
        04|4) echo "network-policy|Network Policy|6|Restrict traffic between namespaces" ;;
        05|5) echo "pv-pvc|Storage|8|PV, PVC, and static provisioning" ;;
        06|6) echo "rbac|RBAC|7|Role, RoleBinding, auth checks" ;;
        07|7) echo "troubleshooting|Troubleshooting|8|Debug CrashLoopBackOff pod" ;;
        08|8) echo "ingress|Ingress|6|Create Ingress with host routing" ;;
        09|9) echo "scheduling|Scheduling|6|Node affinity, taints, tolerations" ;;
        10)    echo "configmap|ConfigMap|4|ConfigMap with volume mount" ;;
        11|11) echo "jobs|Jobs & CronJobs|6|Create Job and CronJob with schedules" ;;
        12|12) echo "etcd-backup|etcd Backup|8|Backup etcd snapshot, restore practice" ;;
        13|13) echo "resources|Resource Limits|5|Set requests and limits on pods" ;;
        14|14) echo "init-containers|Init Containers|6|Multi-stage pod startup" ;;
        15|15) echo "pdb|PodDisruptionBudget|7|Configure PDB for high availability" ;;
        16|16) echo "probes|Probes|6|Liveness, readiness, startup probes" ;;
        17|17) echo "hpa|HPA|6|Horizontal Pod Autoscaler configuration" ;;
        18|18) echo "statefulset|StatefulSet|8|StatefulSet with headless service and PVCs" ;;
        19|19) echo "storage-class|StorageClass|5|Dynamic provisioning with StorageClass" ;;
        20|20) echo "service-accounts|ServiceAccounts|6|ServiceAccount integration with RBAC" ;;
        21|21) echo "coredns|CoreDNS|6|DNS resolution and service discovery" ;;
        22|22) echo "advanced-netpol|Advanced NetworkPolicy|7|Deny-all, namespace isolation" ;;
        23|23) echo "rolling-update|Rolling Update|6|RollingUpdate strategy configuration" ;;
        *) echo "" ;;
    esac
}

# List scenarios
list_scenarios() {
    echo -e "\n${BLUE}Available Scenarios:${NC}\n"

    for i in {1..15}; do
        local id=$(printf "%02d" $i)
        local info=$(get_scenario $id)
        IFS='|' read -r key name time desc <<< "$info"
        if [ -n "$name" ]; then
            echo -e "${GREEN}[$id]${NC} ${CYAN}$name${NC} ${YELLOW}(${time}m)${NC}"
            echo -e "    $desc"
        fi
    done
    echo ""
}

# Timer
start_timer() {
    local minutes=$1
    local end_time=$(($(date +%s) + minutes * 60))

    while true; do
        local now=$(date +%s)
        local remaining=$((end_time - now))

        if [ $remaining -le 0 ]; then
            echo -e "\r${RED}⏰ TIME'S UP!${NC}                    "
            break
        fi

        local mins=$((remaining / 60))
        local secs=$((remaining % 60))
        printf "\r${YELLOW}⏳ %02d:%02d remaining${NC} " $mins $secs
        sleep 1
    done
}

# Show task
show_task() {
    local id="$1"
    local task_file="$SCENARIOS_DIR/${id}-task.md"

    if [ -f "$task_file" ]; then
        cat "$task_file"
    else
        echo -e "${YELLOW}Task file not found. Use generic task template.${NC}"
    fi
}

# Cleanup cluster (safe - only user namespaces)
cleanup_cluster() {
    echo -e "\n${BLUE}Cleaning cluster...${NC}"
    # Delete namespaces (cascades to all resources inside)
    local safe_namespaces="frontend backend development prod storage logging monitoring"
    kubectl --context="$CLUSTER_CTX" delete namespace $safe_namespaces --ignore-not-found=true 2>/dev/null || true
    # Clean default ns (can't delete it)
    kubectl --context="$CLUSTER_CTX" delete pods,deployments,services,ingress,networkpolicies,pvc,configmap,secret -n default --all --ignore-not-found=true 2>/dev/null || true
    echo -e "${GREEN}✓ Cleaned (safe namespaces only)${NC}"
}

# Run single scenario
run_scenario() {
    local input_id="$1"
    local id=$(printf "%02d" ${input_id#0})
    local info=$(get_scenario $input_id)

    if [ -z "$info" ]; then
        echo -e "${RED}Invalid scenario ID: $input_id${NC}"
        return
    fi

    IFS='|' read -r key name time desc <<< "$info"

    clear
    print_header
    echo -e "${GREEN}Scenario $id: $name${NC}"
    echo -e "Time: ${time} minutes | $desc"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Show task
    show_task "$id"

    echo -e "\n${YELLOW}[Timer starts in 3 seconds...]${NC}"
    sleep 3

    # Start timer in background
    start_timer "$time" &
    TIMER_PID=$!

    echo -e "\n${GREEN}Cluster ready. Start working!${NC}"
    echo -e "${YELLOW}(Press ENTER when done to stop timer early)${NC}\n"
    echo "kubectl --context=$CLUSTER_CTX get nodes"
    echo ""

    # Wait for user input OR timer completion
    read -t "$((time * 60))" -r response
    # Kill timer if user pressed ENTER
    kill $TIMER_PID 2>/dev/null || true

    echo -e "\n${CYAN}─────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}Scenario complete!${NC}"
    echo -e "${YELLOW}Review your work:${NC}"
    echo "  kubectl --context=$CLUSTER_CTX get all -A"
    echo ""
    echo -e "Press ENTER to grade, 's' to save, 'r' for solution, or 'q' to quit:"
    read -r response
    if [[ "$response" == "q" ]]; then
        :
    elif [[ "$response" == "s" ]]; then
        save_submission "$id"
    elif [[ "$response" == "r" ]]; then
        echo ""
        show_solution "$id"
    else
        echo ""
        "$BASE_DIR/grade.sh" "$id"
        show_solution "$id"
    fi

    echo -e "\n${YELLOW}Cleanup? (y/n):${NC} "
    read -r cleanup
    if [[ "$cleanup" == "y" ]]; then
        cleanup_cluster
    fi
}

# Show solution
show_solution() {
    local id="$1"
    local solution_file="$SCENARIOS_DIR/${id}-solution.md"

    if [ -f "$solution_file" ]; then
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━ SOLUTION ━━━━━━━━━━━━━━━━━━${NC}"
        cat "$solution_file"
    else
        echo -e "\n${YELLOW}Solution not available yet.${NC}"
    fi
}

# Save submission
save_submission() {
    local id="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local submission_file="$SUBMISSIONS_DIR/${id}-${timestamp}.txt"

    echo -e "\n${CYAN}Enter your commands (one per line, EOF to end):${NC}"
    echo "Press Ctrl+D when done."

    cat > "$submission_file"

    echo -e "\n${GREEN}✓ Saved to: $submission_file${NC}"
    echo -e "${YELLOW}View with: cat $submission_file${NC}"
}

# Random scenario
random_scenario() {
    local random_id=$((RANDOM % 23 + 1))
    run_scenario "$random_id"
}

# Mock exam
run_mock_exam() {
    local exam_num="${1:-1}"
    local exam_file="$BASE_DIR/mock-exam-0${exam_num}.md"

    if [ ! -f "$exam_file" ]; then
        echo -e "${RED}Mock exam $exam_num not found${NC}"
        return
    fi

    clear
    print_header
    echo -e "${GREEN}CKA Mock Exam #$exam_num${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    cat "$exam_file"

    echo -e "\n${YELLOW}Press ENTER to start 30-minute timer:${NC}"
    read -r

    start_timer 30 &
    TIMER_PID=$!

    echo -e "${GREEN}Exam started! Good luck!${NC}\n"
    wait $TIMER_PID 2>/dev/null || true

    echo -e "\n${RED}⏰ TIME'S UP!${NC}"
    echo -e "\nReview your answers in the exam file."
}

# Main menu
show_menu() {
    print_header
    check_cluster
    list_scenarios

    echo -e "${CYAN}Commands:${NC}"
    echo "  practice [id]    - Start scenario (e.g., practice 01)"
    echo "  list             - List all scenarios"
    echo "  random           - Random scenario"
    echo "  exam [1-3]       - Full mock exam"
    echo "  cleanup          - Clean cluster"
    echo "  quit             - Exit"
    echo ""
}

# Main
case "${1:-}" in
    list|"")
        show_menu
        ;;
    [0-9]|[0-9][0-9])
        run_scenario "$1"
        ;;
    random)
        random_scenario
        ;;
    exam)
        run_mock_exam "${2:-1}"
        ;;
    cleanup)
        cleanup_cluster
        ;;
    quit|exit)
        echo "Good luck on CKA!"
        exit 0
        ;;
    *)
        echo "Usage: $0 [scenario-id|random|exam [1-3]|cleanup|list]"
        exit 1
        ;;
esac
