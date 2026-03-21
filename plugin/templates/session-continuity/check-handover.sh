#!/usr/bin/env bash
# Session continuity check — ensures HANDOVER.md and CHANGELOG.md stay current.
#
# Used by Claude Code hooks:
#   1. "Stop" hook — warns when session ends with stale files
#   2. "PostToolUse" hook on git commit — warns after commits when files are stale
#
# Usage:
#   ./scripts/check-handover.sh              # Stop hook mode (warn only)
#   ./scripts/check-handover.sh --pre-commit  # Post-commit mode (stricter)
#
# Setup:
#   1. Copy this file to <repo>/scripts/check-handover.sh
#   2. chmod +x scripts/check-handover.sh
#   3. Merge hooks.json into your .claude/settings.local.json

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || exit 0

MODE="${1:-stop}"
WARNINGS=""

# ---------------------------------------------------------------------------
# Detect if meaningful work was done
# ---------------------------------------------------------------------------

# Changed files (excluding handover/changelog themselves)
WORK_CHANGES=$(git status --porcelain 2>/dev/null \
  | grep -v 'HANDOVER.md' \
  | grep -v 'CHANGELOG.md' \
  | grep -v '??' \
  | head -1)

# Commits in the last 2 hours (covers longer sessions)
RECENT_COMMITS=$(git log --since="2 hours ago" --oneline 2>/dev/null \
  | grep -v 'Update HANDOVER' \
  | grep -v 'Update CHANGELOG' \
  | grep -v 'handover' \
  | head -1)

# No work done → nothing to warn about
if [ -z "$WORK_CHANGES" ] && [ -z "$RECENT_COMMITS" ]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Check HANDOVER.md (skip if gitignored — it's a local-only file)
# ---------------------------------------------------------------------------

HANDOVER_IGNORED=$(git check-ignore "$REPO_ROOT/HANDOVER.md" 2>/dev/null)
TODAY=$(date +%Y-%m-%d)

if [ -z "$HANDOVER_IGNORED" ]; then
  HANDOVER_TOUCHED=$(git status --porcelain 2>/dev/null | grep 'HANDOVER.md')
  HANDOVER_COMMITTED=$(git log --since="2 hours ago" --oneline -- HANDOVER.md 2>/dev/null | head -1)

  if [ -z "$HANDOVER_TOUCHED" ] && [ -z "$HANDOVER_COMMITTED" ]; then
    WARNINGS="${WARNINGS}\n⚠  HANDOVER.md was not updated this session."
  fi

  HANDOVER_DATE=$(head -1 "$REPO_ROOT/HANDOVER.md" 2>/dev/null | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}')
  if [ -n "$HANDOVER_DATE" ] && [ "$HANDOVER_DATE" != "$TODAY" ]; then
    WARNINGS="${WARNINGS}\n⚠  HANDOVER.md date is ${HANDOVER_DATE}, but today is ${TODAY}."
  fi
fi

# ---------------------------------------------------------------------------
# Check CHANGELOG.md
# ---------------------------------------------------------------------------

CHANGELOG_TOUCHED=$(git status --porcelain 2>/dev/null | grep 'CHANGELOG.md')
CHANGELOG_COMMITTED=$(git log --since="2 hours ago" --oneline -- CHANGELOG.md 2>/dev/null | head -1)

if [ -z "$CHANGELOG_TOUCHED" ] && [ -z "$CHANGELOG_COMMITTED" ]; then
  WARNINGS="${WARNINGS}\n⚠  CHANGELOG.md was not updated this session."
fi

if ! grep -q "## ${TODAY}" "$REPO_ROOT/CHANGELOG.md" 2>/dev/null; then
  WARNINGS="${WARNINGS}\n⚠  CHANGELOG.md has no entry for today (${TODAY})."
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

if [ -n "$WARNINGS" ]; then
  if [ "$MODE" = "--pre-commit" ]; then
    echo -e "🔒 Session continuity check (post-commit):${WARNINGS}"
    echo ""
    echo "Update HANDOVER.md and CHANGELOG.md, then amend or create a follow-up commit."
    exit 1
  else
    echo -e "📋 Session continuity reminder:${WARNINGS}"
    echo ""
    echo "Ask Claude to update these before ending the session."
  fi
else
  if [ "$MODE" = "--pre-commit" ]; then
    echo "✅ CHANGELOG.md and HANDOVER.md are up to date."
  fi
fi
