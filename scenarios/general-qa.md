# General CKA Practice - Q&A

## Questions & Answers

### Q: What is the CKA exam format?
**A:** 2 hours, 15-20 tasks, all hands-on:
- No multiple choice
- No theory questions
- Just run commands to solve problems
- Graded by cluster state (not your commands)

---

### Q: What types of tasks will I see?
**A:**
| Type | Example | Frequency |
|------|---------|-----------|
| Create | "Deploy nginx with 3 replicas" | ~40% |
| Fix/Debug | "Pod stuck in CrashLoopBackOff" | ~25% |
| Update | "Update deployment, rollout, rollback" | ~15% |
| Configure | "Create NetworkPolicy, RBAC" | ~15% |
| Troubleshoot | "Cluster not working" | ~5% |

---

### Q: How does grading work?
**A:** Exam checks cluster state (like your `./grade.sh`):
- Deployment exists? ✓
- Image correct? ✓
- Replicas correct? ✓
- NOT "which command you used"

---

### Q: Should I run grade after each step or at end?
**A:** At end only. Grader checks:
- Current state (deployment, replicas, etc.)
- History (revisions = updates happened)
- No need to grade mid-task

---

### Q: What's the passing score?
**A:** 67% to pass.

---

### Q: How to save terminal output for review?
**A:**
```bash
# Redirect to file
k get pods -A > output.txt

# Append with timestamps
k get pods -A | tee -a history.txt

# iTerm2: Select text → Right-click → Save as...
```

---

### Q: Can I use Kubernetes docs during exam?
**A:** Yes! Docs tab is available during exam. Bookmark kubernetes.io/docs.

---

### Q: Will the real exam include hints like in these practice scenarios?
**A:** No. Real exam provides only task requirements. No hints section. You get task text, figure it out yourself using docs. Practice scenarios include hints for learning; exam tests your ability to solve without guidance.

---

### Q: Should I practice on Killercoda or local cluster?
**A:** Both:
- **Local cluster** (your kind): Daily muscle memory, command speed
- **Killercoda**: Exam interface familiarity (browser-based terminal)

---

### Q: How to make cluster end early in practice script?
**A:** Updated! Just press ENTER when done - timer stops automatically.

---

### Q: What are the options after scenario?
**A:**
- ENTER → grade + solution
- 's' → save commands
- 'r' → solution only
- 'q' → quit

---

### Q: Why did cleanup script not remove taints?
**A:** Bug in taint removal syntax - now fixed:
```bash
# Old (wrong)
kubectl taint nodes $node dedicated:NoSchedule-

# New (correct)
kubectl taint nodes $node dedicated=prod:NoSchedule-
```

Must match full taint spec (key=value:effect).

## Exam Tips
- Imperative commands save time (`kubectl run`, `expose`, `scale`)
- `--dry-run=client -o yaml` for YAML templates
- `--help` is your friend during exam
- Focus on completing tasks, not perfection
- Skip and return if stuck
