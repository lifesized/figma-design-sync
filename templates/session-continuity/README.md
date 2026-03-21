# Session Continuity Hooks

Ensures HANDOVER.md and CHANGELOG.md stay current across Claude Code sessions.

## Setup

1. Copy the script into your repo:
   ```bash
   cp ~/.claude/templates/session-continuity/check-handover.sh <repo>/scripts/
   chmod +x <repo>/scripts/check-handover.sh
   ```

2. Merge the hooks from `hooks.json` into `<repo>/.claude/settings.local.json`.

3. Add session continuity instructions to your CLAUDE.md:
   ```markdown
   ## Session continuity
   Before ending a session or when context exceeds ~75%, update:
   1. **HANDOVER.md** — what was done, key files, current state, next steps
   2. **CHANGELOG.md** — user-facing changes under dated heading
   ```

4. Optional: add `HANDOVER.md` to `.gitignore` if you want it local-only.

## How it works

- **On Stop**: warns if files weren't updated this session
- **After git commit**: warns if files are stale, shows ✅ when current
- Skips HANDOVER.md checks if it's gitignored
- Only fires when meaningful work was done (has uncommitted changes or recent commits)
