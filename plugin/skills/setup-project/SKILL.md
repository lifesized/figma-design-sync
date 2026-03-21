---
name: setup-project
description: Onboard a new codebase for design system sync and session continuity. Detects tokens, sets up hooks, runs baseline audit. Activate with "/setup-project".
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, AskUserQuestion, mcp__figma-console__figma_get_status, mcp__figma-console__figma_get_variables, mcp__figma-console__figma_execute, mcp__figma-console__figma_pair_plugin
---

# Setup Project (Global)

Onboard a new codebase for design system tooling and session continuity.

## When to use

Run `/setup-project` when joining a new repo for the first time. It sets up:
1. Session continuity hooks (HANDOVER.md + CHANGELOG.md automation)
2. Design token detection and Figma sync configuration
3. Baseline UI state audit

## Workflow

### Step 1: Detect the project

Read the project to understand:
- Framework (Next.js, Vite, CRA, etc.)
- CSS approach (Tailwind, CSS modules, styled-components, vanilla CSS)
- Component library (custom, shadcn, MUI, etc.)
- Existing design tokens (`:root` vars, Tailwind config, theme files, design-system.json)

### Step 2: Session continuity

ASK the user if they want session continuity hooks. If yes:

1. Copy `~/.claude/templates/session-continuity/check-handover.sh` → `<repo>/scripts/`
2. Make it executable
3. Merge hooks from `~/.claude/templates/session-continuity/hooks.json` into `<repo>/.claude/settings.local.json`
4. Create a starter `HANDOVER.md` with today's date
5. Create a starter `CHANGELOG.md` if one doesn't exist
6. Add session continuity instructions to `CLAUDE.md` if it exists
7. ASK if `HANDOVER.md` should be gitignored (recommend yes)

### Step 3: Design system extraction

There are two paths depending on what exists:

#### Path A: Tokens already exist

If the project has a `:root` block, Tailwind config, theme file, or design-system.json — map what's there.

#### Path B: No formal design system (Lovable, v0, Bolt, or just hacking)

If no tokens file exists, extract the implicit design system from the codebase:

1. **Scan for colors** — grep for hex values (`#xxx`, `#xxxxxx`), `rgb()`, `hsl()`, Tailwind color classes (`bg-zinc-900`, `text-gray-400`), and inline style colors. Group similar values (e.g. `#1a1a1a` and `#1b1b1b` are likely the same intent).

2. **Scan for typography** — find font families, font sizes, font weights, line heights across CSS, Tailwind classes, and inline styles.

3. **Scan for spacing & radii** — find padding, margin, gap, border-radius values. Look for repeated patterns.

4. **Present findings** — show the user what was found:
   - "You're using 14 unique colors — here are the 8 that appear most, with suggested names"
   - "You have 5 font sizes — here's a proposed type scale"
   - "You're using 4 border-radius values — here's a proposed set"
   - Flag near-duplicates and suggest consolidation

5. **ASK the user** to confirm, adjust names, or merge duplicates.

6. **Generate a token file** — create a canonical CSS file with `:root` custom properties (or Tailwind config extension, whichever fits the project). This becomes the source of truth going forward.

7. **Optionally refactor** — ASK if the user wants to replace hardcoded values in components with the new tokens. This is a bigger change so always confirm first.

#### After either path, create sync configs:

1. Create `.agents/skills/sync-to-figma/SKILL.md` with:
   - Path to the canonical token file (e.g. `app/globals.css`, `src/tokens.css`)
   - Token name → Figma variable name mapping rules
   - Which CSS custom properties map to colors, spacing, radii, typography
   - Component inventory (detected from `components/` directory)
   - Theme info (single theme, light/dark, multi-brand)

2. Create `.agents/skills/sync-from-figma/SKILL.md` with:
   - Same token file path
   - Figma collection name to look for
   - Reverse mapping rules (Figma variable names → CSS property names)

### Step 4: Figma connection (optional)

ASK if the user wants to connect to Figma now. If yes:

1. Check if Figma Console MCP is configured (`figma_get_status`)
2. If not connected, guide through Desktop Bridge plugin pairing
3. Check for existing variable collections
4. If collections exist, map them to detected CSS tokens
5. If no collections, note that `/sync-to-figma` will create them on first run

### Step 5: Baseline audit (optional)

ASK if the user wants a UI state audit. If yes:

1. Run `/design-audit-states` to assess current state coverage
2. Save the results summary as a note in the project CLAUDE.md or a markdown file

### Step 6: Summary

Print a summary of what was set up:
- Session continuity: hooks installed / skipped
- Token file: path and token count
- Figma: connected / not connected
- State coverage: X% baseline / skipped
- Next steps: suggested first actions

## Important notes

- Never overwrite existing CLAUDE.md, CHANGELOG.md, or settings files — merge into them
- All file creation requires user confirmation
- The project-specific skill files (`.agents/skills/`) are meant to be committed to the repo
- The session continuity template lives at `~/.claude/templates/session-continuity/`
