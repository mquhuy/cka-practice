# CKA Study Project - AI Instructions

## Project Overview
CKA (Certified Kubernetes Administrator) exam preparation with local practice cluster and scenarios.

## Session Context
- User is preparing for CKA exam in a few weeks
- Focus on hands-on practice with kind cluster
- Teaching mode: Walk through solutions, not do work for user
- Grade work, show tips for incorrect answers

## Important Instructions

### Q&A Saving
**Whenever user asks conceptual questions or needs explanations:**
1. Save the Q&A to scenario-specific markdown files
2. Organize by scenario number (01-qa.md, 02-qa.md, etc.)
3. Create general-qa.md for exam-format questions
4. Include code examples and commands

**File structure:**
```
/Users/huy/Projects/CKA/scenarios/
├── 01-qa.md          # Scenario 01 Q&A
├── 02-qa.md          # Scenario 02 Q&A
├── 03-qa.md          # Scenario 03 Q&A
├── 09-qa.md          # Scenario 09 Q&A
├── services-qa.md    # Cross-topic Q&A
├── general-qa.md     # Exam format, tips
└── README-qa.md      # Index
```

**Format for Q&A files:**
```markdown
# Scenario XX: Topic - Q&A

## Questions & Answers

### Q: Question text?
**A:** Answer with explanation.

Include code examples and commands where helpful.

## Key Commands
```bash
# Important commands for this scenario
```
```

### When to save Q&A
- User asks "why", "how", "what is X"
- Grading reveals misconception
- User confused about concept
- Best practice explanation needed
- Command syntax questions

## Current Setup

### Cluster
- **Name:** cka-practice (kind)
- **Nodes:** 3 (1 control-plane, 2 workers)
- **Context:** kind-cka-practice
- **K8s Version:** 1.33.1

### Practice System
- **Main script:** `./exam-practice.sh [scenario-id]`
- **Grading:** `./grade.sh [scenario-id]`
- **Cleanup:** `./cleanup.sh`
- **Timer:** `./timer.sh`

### Progress
- ✅ Scenario 01: Deployments
- ✅ Scenario 02: Multi-container pods
- ✅ Scenario 03: Node maintenance
- ⏳ Scenarios 04-10: Pending

## Key Concepts Covered

### Services & Ports
- NodePort vs Service Port vs TargetPort vs ContainerPort
- `kubectl create svc` vs `kubectl expose`
- How services link to pods (selectors)

### Scheduling
- Node selector (hard requirement)
- Preferred affinity (soft preference with weights)
- Required affinity (must match)
- Taints (repel pods)
- Tolerations (allow through taints)

### Node Maintenance
- Cordon vs drain
- Why `--ignore-daemonsets` needed
- DaemonSet behavior

### Commands Reference
```bash
# Image update
kubectl set image deployment/<name> <container>=<image>

# Rollback
kubectl rollout undo deployment/<name>

# Taints
kubectl taint nodes <node> key=value:effect
kubectl taint nodes <node> key=value:effect-

# Labels
kubectl label node <node> key=value
kubectl label node <node> key-

# Drain
kubectl cordon <node>
kubectl drain <node> --ignore-daemonsets
kubectl uncordon <node>
```

## Exam Tips
- Exam grades cluster state, not commands
- Use imperative commands for speed
- `--dry-run=client -o yaml` for YAML templates
- Docs available during exam
- 67% to pass

## Files
- `kind-cluster.yaml` - Cluster config
- `cka-commands.md` - Command reference
- `mock-exam-*.md` - Full practice exams
- `study-tracker.md` - 4-week study plan
