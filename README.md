# Figma Design Sync

Agent skills for syncing design systems between code and Figma. Code is the source of truth — Figma is the mirror.

## Install

### Claude Code

```bash
# Add the marketplace (one time)
claude plugin marketplace add lifesized/figma-design-sync

# Install the plugin
claude plugin install figma-design-sync@lifesized
```

### Cursor / Kilocode / other MCP-compatible agents

Clone the repo and copy the skill files into your agent's rules or instructions directory:

```bash
git clone https://github.com/lifesized/figma-design-sync.git
cp -r figma-design-sync/plugin/skills/* ~/.cursor/skills/   # Cursor
# or wherever your agent reads skill/rule files from
```

For [Kilocode](https://kilocode.ai) (VS Code extension), add the SKILL.md content to your custom instructions and configure Figma Console MCP as an MCP server in the extension settings.

The skills are plain markdown files — any agent that supports instruction files and can connect to [Figma Console MCP](https://github.com/southleft/figma-console-mcp) can use them.

### OpenAI Codex / ChatGPT

Codex and ChatGPT can use these skills if you have Figma Console MCP configured as an MCP server in your environment. Add the SKILL.md content as custom instructions or system prompts, and ensure the MCP tools (`figma_execute`, `figma_get_variables`, etc.) are available to the agent.

### Manual install (any agent)

```bash
git clone https://github.com/lifesized/figma-design-sync.git
cp -r figma-design-sync/plugin/skills/* ~/.claude/skills/
```

## What's included

| Skill | Command | What it does |
|-------|---------|-------------|
| **sync-to-figma** | `/sync-to-figma` | Push CSS tokens → Figma variables + component state artboards |
| **sync-from-figma** | `/sync-from-figma` | Diff Figma variables against CSS tokens (audit mode) |
| **setup-project** | `/setup-project` | Onboard a new codebase: detect tokens, install hooks, baseline audit |

## Prerequisites

- [Figma Console MCP](https://github.com/southleft/figma-console-mcp) by [Southleft](https://figma-console-mcp.southleft.com/) — MCP server with 59+ tools for reading/writing design tokens, components, and variables. Includes the Desktop Bridge plugin for Figma. See their [setup guide](https://docs.figma-console-mcp.southleft.com/setup) for installation.
- Figma Desktop app
- A frontend codebase — don't have a design system? No worries. Run `/setup-project` and it'll scan your code to find the one hiding in there already

## Connecting to Figma

These skills use **Cloud Mode** — the recommended connection for AI coding agents like Claude Code. Cloud mode gives you 44 tools with full write access, no local Node.js server needed. Your AI agent connects to Figma through a cloud relay, and the Desktop Bridge plugin running in your Figma file handles the other end.

### Setup (once)

1. Add the Figma Console MCP server to your AI client ([setup guide](https://docs.figma-console-mcp.southleft.com/setup))
2. Open the Desktop Bridge plugin in your Figma file

### Pairing (each session)

1. Your AI agent generates a 6-character pairing code (expires in 5 minutes)
2. In the Desktop Bridge plugin: toggle **Cloud Mode** → enter the code → click **Connect**
3. The connection is now live — the agent can read and write to your open Figma file

### Important notes

- The Desktop Bridge plugin **must stay running** in your Figma file for the connection to work
- The connection is **per-file** — if you switch Figma files, you need to re-pair
- Variables are **file-global** (not page-scoped), so token syncing works across all pages
- Artboards are created on the **current page** — navigate to the right page before syncing
- If pairing fails or `get_variables` returns errors, the skills fall back to `figma_execute` which runs code directly through the plugin console

### Connection modes compared

| Mode | Tools | Write access | Best for |
|------|-------|-------------|----------|
| **Cloud** (recommended) | 44 | Yes | AI coding agents (Claude Code, Cursor) |
| Local | 63+ | Yes | Full real-time tracking, console monitoring |
| Remote | 9 | No | Quick read-only exploration |

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

## What the MCP can do in Figma

These skills use a subset of Figma Console MCP's capabilities. If you want to extend them or build your own skills, here's what's available:

### Read

- **Variables & tokens** — read all variable collections, modes, values; export as CSS, Tailwind, Sass, or JSON
- **Components** — inspect structure, variant axes, properties, sub-components, slot relationships
- **Nodes** — read any node's fills, strokes, text, layout, size, position, corner radius, effects
- **Screenshots** — capture any node or frame as an image for visual verification
- **Styles** — read shared color, text, and effect styles
- **Accessibility** — WCAG contrast checking and accessibility linting

### Write

- **Variables** — create collections, create/update/delete variables, set values per mode
- **Nodes** — create rectangles, frames, text, groups; set fills, strokes, text content, resize, move, rename, delete
- **Variable bindings** — bind any fill, stroke, or dimension to a variable (`setBoundVariableForPaint`, `setBoundVariable`)
- **Components** — create component sets, add/edit/delete component properties, arrange variants
- **Instances** — instantiate components, set instance properties
- **Images** — set image fills, export nodes as PNG/JPEG/WEBP/PDF
- **Pages** — navigate between pages (artboards are created on the current page)

### Execute

- **`figma_execute`** — run arbitrary JavaScript in Figma's plugin context with full access to the `figma` API. This is the escape hatch — anything the Figma Plugin API supports, you can do.

### Limitations

- **Cloud mode**: 44 tools (no real-time selection tracking or console monitoring — those need local mode)
- **FigJam**: not fully supported — these skills target Figma design files
- **Variables API**: works on any Figma plan via the Plugin API (not the Enterprise REST API)
- **Per-file scope**: the connection is to one open Figma file at a time
- **No version history access**: can't read or write to Figma's built-in version history

## Inspired by

- [Uber's uSpec](https://www.uber.com/en-CA/blog/automate-design-specs/) — modular agent skills for Figma spec generation
- The idea that design documentation should be generated from code, not maintained by hand

## Credits

- [Southleft](https://southleft.com/) — built [Figma Console MCP](https://figma-console-mcp.southleft.com/), the open-source infrastructure layer that makes this possible. These skills would not exist without their MCP server providing direct read/write access to Figma's plugin API.

## License

MIT
