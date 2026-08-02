# CKA Exam Practice Lab

Local Kubernetes practice environment for Certified Kubernetes Administrator (CKA) exam preparation. Killercoda-style interface with your own kind cluster.

## Features

- 🎯 10+ hands-on scenarios covering CKA domains
- ⏱️ Built-in timer for exam-style practice
- ✅ Auto-grading for cluster state verification
- 📝 Command submission tracking
- 🧹 One-click cluster cleanup
- 📚 Q&A knowledge base by scenario

## Prerequisites

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install kind
brew install kind

# Verify
kubectl version --client
kind version
```

## Quick Start

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/cka-practice.git
cd cka-practice

# Create cluster
kind create cluster --config=kind-cluster.yaml --name=cka-practice

# Verify
kubectl --context=kind-cka-practice get nodes

# Start practicing
./exam-practice.sh
```

## Usage

### Interactive Menu
```bash
./exam-practice.sh          # Show menu with all scenarios
./exam-practice.sh list      # List all scenarios
```

### Direct Scenario Run
```bash
./exam-practice.sh 01        # Run scenario 01 (Deployments)
./exam-practice.sh 5         # Run scenario 05 (Storage)
```

### Other Commands
```bash
./exam-practice.sh random    # Random scenario
./exam-practice.sh exam 1    # Mock exam #1
./exam-practice.sh cleanup   # Clean cluster
```

### Grading
```bash
./grade.sh 01                # Grade scenario 01
```

### Timer Standalone
```bash
./timer.sh 15                # 15-minute countdown timer
```

## Project Structure

```
cka-practice/
├── exam-practice.sh         # Main interactive script
├── grade.sh                 # Grading script
├── submit.sh                # Save submissions
├── timer.sh                 # Countdown timer
├── cleanup.sh               # Cluster cleanup
├── kind-cluster.yaml        # kind cluster config
├── scenarios/
│   ├── 01-task.md          # Scenario tasks
│   ├── 01-solution.md      # Reference solutions
│   ├── 01-qa.md            # Q&A for scenario
│   ├── general-qa.md       # General exam Q&A
│   └── README-qa.md        # Q&A index
├── manifests/
│   └── metrics-server.yaml # Metrics server for cluster
├── mock-exam-01.md         # Full practice exams
├── cka-commands.md         # Command cheat sheet
├── study-tracker.md        # 4-week study plan
└── README.md
```

## Scenarios

| ID | Topic | Time | Description |
|----|-------|------|-------------|
| 01 | Deployments | 5m | Create, scale, update, rollback |
| 02 | Multi-Container Pods | 4m | Sidecar containers, shared volumes |
| 03 | Node Maintenance | 5m | Cordon, drain, uncordon |
| 04 | Network Policy | 6m | Traffic restrictions |
| 05 | Storage | 8m | PV, PVC, static provisioning |
| 06 | RBAC | 7m | Roles, RoleBindings |
| 07 | Troubleshooting | 8m | Debug failing pods |
| 08 | Ingress | 6m | Host-based routing |
| 09 | Scheduling | 6m | Affinity, taints, tolerations |
| 10 | ConfigMap | 4m | Configuration as volume |

## Exam Tips

1. **Bookmark docs**: kubernetes.io/docs (allowed during exam)
2. **Imperative commands**: `kubectl run`, `expose`, `scale` save time
3. **Use aliases**: `alias k=kubectl` (pre-configured in exam)
4. **Don't overthink**: Most tasks straightforward
5. **Use dry-run**: `--dry-run=client -o yaml` for YAML generation
6. **67% to pass**: Focus on completing tasks correctly

## Recommended Study Path

**Week 1**: Core concepts (scenarios 01-03)
- Pods, Deployments, basic Services

**Week 2**: Advanced workloads (scenarios 04-05)
- Networking, storage

**Week 3**: Cluster operations (scenarios 06-09)
- RBAC, troubleshooting, scheduling

**Week 4**: Mock exams + speed drills
- Time yourself, focus on imperative commands

## License

MIT License - feel free to use, modify, and share.

## Contributing

Found a bug? Have a scenario to add? Issues and PRs welcome!

---

**Good luck on your CKA exam! 🚀**
