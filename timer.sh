#!/bin/bash
# CKA Exam Timer

start_time=$(date +%s)
duration=20  # minutes

echo "🚀 CKA Mock Exam Started!"
echo "⏱️  Time limit: ${duration} minutes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while true; do
    current=$(date +%s)
    elapsed=$((current - start_time))
    remaining=$((duration * 60 - elapsed))

    if [ $remaining -le 0 ]; then
        echo ""
        echo "⏰ TIME'S UP!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        break
    fi

    mins=$((remaining / 60))
    secs=$((remaining % 60))

    printf "\r⏳ Remaining: %02d:%02d " $mins $secs
    sleep 1
done

echo ""
echo "📊 Check your work:"
echo "  kubectl get all -A"
echo "  kubectl get nodes"
echo ""
