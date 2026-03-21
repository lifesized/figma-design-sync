# Figma Design Sync

Agent skills for syncing design systems between code and Figma. Code is the source of truth — Figma is the mirror.

## Install

```bash
npx skillsadd tofumajure/figma-design-sync
```

## What's included

| Skill | Command | What it does |
|-------|---------|-------------|
| **sync-to-figma** | `/sync-to-figma` | Push CSS tokens → Figma variables + component state artboards |
| **sync-from-figma** | `/sync-from-figma` | Diff Figma variables against CSS tokens (audit mode) |
| **setup-project** | `/setup-project` | Onboard a new codebase: detect tokens, install hooks, baseline audit |

## Prerequisites

- [Figma Console MCP](https://github.com/nicholasberggaard/figma-console-mcp) — connects your AI agent to Figma Desktop
- Figma Desktop app with the Desktop Bridge plugin
- A codebase with CSS custom properties, Tailwind, or a design token file

## How it works

### Code-first design systems

Your CSS/Tailwind defines the design system. These skills push that truth into Figma as native variables and component documentation. When code changes, re-sync. Figma always reflects current code.

### Atomic token binding

Every visual property in Figma is bound to a Figma variable — never raw hex colors or hardcoded values. Color fills use `setBoundVariableForPaint()`, spacing uses `setBoundVariable()`. Click any element in Figma and you see the token name, not a mystery color.

### Visual git

Variables and artboards follow a git-like model:

| Git concept | Figma equivalent |
|---|---|
| `HEAD` / `main` | Variable collection (one, always current) |
| Working tree | Current page (artboards bound to live variables) |
| Commit | Archived page (frozen snapshot with date stamp) |

- `/sync-to-figma` — updates in-place (like editing your working tree)
- `/sync-to-figma --fresh` — snapshots current page, creates new one (like a commit)
- `/sync-to-figma --tokens-only` — variables only, skip artboards
- `/sync-to-figma --component Button` — sync a single component

### Session continuity

The `setup-project` skill installs hooks that keep `HANDOVER.md` and `CHANGELOG.md` current:
- **After git commit**: warns if files are stale, confirms when current
- **On session end**: reminds to update before closing

## Sync-to-Figma output

The skill generates:

- **Color Palette** — square swatches bound to variables, grouped by category
- **Typography** — fonts in realistic UI contexts + type scale
- **Spacing & Radii** — visual bars and radius samples
- **Component artboards** — one per component, all states in a variant × state grid (default, hover, focus, active, disabled, loading)

All fills, borders, and text colors are token-bound. Dark-theme artboards use visible surface colors so components aren't invisible.

## Project-specific configuration

After running `/setup-project`, you'll have project-specific mapping files:

```
.agents/skills/sync-to-figma/SKILL.md   # Token file path, name mappings, component list
.agents/skills/sync-from-figma/SKILL.md  # Reverse mappings, collection name
```

These tell the global skills where your tokens live and how to map them.

## Inspired by

- [Uber's uSpec](https://www.uber.com/en-CA/blog/automate-design-specs/) — modular agent skills for Figma spec generation
- The idea that design documentation should be generated from code, not maintained by hand

## License

MIT
