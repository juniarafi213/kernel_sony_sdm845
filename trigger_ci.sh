#!/usr/bin/env bash
# Trigger GitHub Actions kernel build for Sony SDM845 (Akari KDDI)
set -e

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_REPO="/home/jun/workflow_repo"

TARGET_BRANCH="${1:-$(git -C "$WORK_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'bore-cass')}"

if [ ! -d "$WORKFLOW_REPO/.git" ]; then
    echo "Error: workflow_repo not found at $WORKFLOW_REPO"
    exit 1
fi

echo "=========================================================="
echo " Triggering GitHub Actions CI for Sony SDM845 Kernel"
echo " Target Kernel Branch: $TARGET_BRANCH"
echo " Target Device: Akari KDDI (Sony Xperia XZ2)"
echo "=========================================================="

echo "$TARGET_BRANCH" > "$WORKFLOW_REPO/target_branch.txt"
echo "$(date -u +'%Y-%m-%d %H:%M:%S UTC') by Antigravity / $(whoami)" > "$WORKFLOW_REPO/trigger_akari.txt"

cd "$WORKFLOW_REPO"
git add target_branch.txt trigger_akari.txt .github/workflows/akari_kddi_ksun.yml
if git diff --cached --quiet; then
    # In case files didn't change, force a touch
    date +%s%N > trigger_akari.txt
    git add trigger_akari.txt
fi

git commit -m "build(akari): auto-trigger kernel build for branch $TARGET_BRANCH ($(date +'%Y-%m-%d %H:%M:%S'))"
git push origin main

echo ""
echo "✓ Workflow successfully triggered on GitHub Actions!"
echo "  Workflow: AKARI KDDI KSUN"
echo "  Branch: $TARGET_BRANCH"
echo "  Check progress at: https://github.com/juniarafi213/workflow/actions"
echo "  Output zip will be sent automatically to your Telegram!"
echo "=========================================================="
