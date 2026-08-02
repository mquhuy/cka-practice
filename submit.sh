#!/bin/bash
# CKA Exam Submission - Save commands for grading
# Usage: ./submit.sh [scenario-id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBMISSIONS_DIR="$SCRIPT_DIR/submissions"
mkdir -p "$SUBMISSIONS_DIR"

scenario_id="${1:-$(basename $(pwd))}"
timestamp=$(date +%Y%m%d-%H%M%S)
submission_file="$SUBMISSIONS_DIR/${scenario_id}-${timestamp}.sh"

cat > "$submission_file" <<'SUBMIT_EOF'
#!/bin/bash
# CKA Scenario Submission
# Scenario: SCENARIO_ID
# Submitted: TIMESTAMP

CONTEXT="kind-cka-practice"

# ===== YOUR COMMANDS BELOW =====
# Replace with your actual commands

SUBMIT_EOF

echo "# Submission for Scenario $scenario_id" >> "$submission_file"
echo "# Timestamp: $timestamp" >> "$submission_file"
echo "" >> "$submission_file"
echo "# ===== YOUR COMMANDS =====" >> "$submission_file"
echo "# Paste your commands between the markers" >> "$submission_file"
echo "" >> "$submission_file"
echo "cat <<'COMMANDS'" >> "$submission_file"
echo "# Add your kubectl commands here, one per line" >> "$submission_file"
echo "# Example:" >> "$submission_file"
echo "# kubectl create deployment web --image=nginx:1.27 --replicas=3" >> "$submission_file"
echo "COMMANDS" >> "$submission_file"

echo -e "${GREEN}Submission file created:${NC} $submission_file"
echo -e "${YELLOW}Edit the file and add your commands, then run:${NC}"
echo -e "  ./grade.sh $scenario_id $timestamp"
