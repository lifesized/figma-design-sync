# Figma Design Sync

Push your design system from code to Figma. Your CSS tokens become Figma variables, your components become documented artboards with every state. Built on [Figma Console MCP](https://github.com/southleft/figma-console-mcp) by [Southleft](https://figma-console-mcp.southleft.com/).

> **Not the same as Figma MCP.** Figma's own MCP is read-only. [Figma Console MCP](https://figma-console-mcp.southleft.com/) reads *and writes* — variables, nodes, token bindings, everything. These skills require it.

## Install

### Claude Code

```bash
claude plugin marketplace add lifesized/figma-design-sync
claude plugin install figma-design-sync@lifesized
```

### Cursor / Kilocode / Codex / other agents

```bash
git clone https://github.com/lifesized/figma-design-sync.git
cp -r figma-design-sync/plugin/skills/* ~/.cursor/skills/   # or wherever your agent reads skills
```

The skills are markdown files — any agent that supports instruction files and connects to Figma Console MCP can use them.

## What you get

| Skill | Command | What it does |
|-------|---------|-------------|
| **sync-to-figma** | `/sync-to-figma` | Push CSS tokens → Figma variables + component state artboards |
| **sync-from-figma** | `/sync-from-figma` | Diff Figma variables against your CSS (audit mode, dry-run by default) |
| **setup-project** | `/setup-project` | Scan your codebase, extract tokens, configure sync |

## Prerequisites

- [Figma Console MCP](https://github.com/southleft/figma-console-mcp) — [setup guide](https://docs.figma-console-mcp.southleft.com/setup)
- Figma Desktop
- A frontend codebase — no design system yet? Run `/setup-project` and it'll find the one hiding in your code

## Quick start

1. Install Figma Console MCP and open the Desktop Bridge plugin in your Figma file
2. Tell your AI agent "connect to Figma" — it'll generate a 6-character pairing code → enter it in the Desktop Bridge plugin's Cloud Mode → Connect
3. Navigate to the Figma page you want your design system on — **stay on this page** (the connection is per-page)
4. Run `/setup-project` to detect your tokens
5. Run `/sync-to-figma` to push everything to Figma

## How it works

**Code → Figma.** Your CSS custom properties and Tailwind classes define the design system. These skills push that into Figma as native variables and component documentation. Every fill, border, and text color is bound to a Figma variable — click any element and you see the token name, not a mystery hex color.

**Flags:**

- `/sync-to-figma` — update existing artboards in-place
- `/sync-to-figma --fresh` — snapshot current page, create a new version (visual git)
- `/sync-to-figma --tokens-only` — variables only, skip artboards
- `/sync-to-figma --component Button` — sync one component

**What gets generated:**

- Color Palette — square swatches bound to variables
- Typography — fonts in context + type scale
- Spacing & Radii — visual samples
- Component artboards — one per component, all states (default, hover, focus, active, disabled, loading)

**No design system?** `/setup-project` scans your codebase for scattered colors, font sizes, spacing values, groups near-duplicates, and proposes a consolidated token file. Works with Lovable, v0, Bolt, or any hand-coded project.

## Connecting to Figma

These skills use **Cloud Mode** — no local Node.js needed. The Desktop Bridge plugin must stay running in your Figma file. Connection is per-file. If pairing fails, the skills fall back to `figma_execute`.

| Mode | Tools | Write | Best for |
|------|-------|-------|----------|
| **Cloud** | 44 | Yes | AI coding agents |
| Local | 63+ | Yes | Real-time tracking |
| Remote | 9 | No | Read-only exploration |

## Extending these skills

These use a subset of Figma Console MCP's 59+ tools. Build your own skills with full access to variables, components, nodes, screenshots, accessibility linting, and `figma_execute` (arbitrary Plugin API JavaScript). See [their docs](https://docs.figma-console-mcp.southleft.com/) for the full API.

## Part of a bigger movement

- [Uber's uSpec](https://www.uber.com/en-CA/blog/automate-design-specs/) — agent skills for Figma spec generation, built on Figma Console MCP
- [Romina Kavcic](https://thedesignsystem.guide) — Agentic Design Systems framework (Into Design Systems 2026)
- [Southleft](https://figma-console-mcp.southleft.com/) — the open-source infrastructure layer. [TJ Pitre](https://www.linkedin.com/in/tjpitre/) and team built the foundation that makes all of this possible.

## License

MIT
