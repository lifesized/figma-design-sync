# Figma Design Sync

Push your design system from code to Figma. Your CSS tokens become Figma variables, your components become documented artboards with every state. Built on [Figma Console MCP](https://github.com/southleft/figma-console-mcp) by [Southleft](https://figma-console-mcp.southleft.com/).

> **Not the same as Figma MCP.** Figma's own MCP is read-only. [Figma Console MCP](https://figma-console-mcp.southleft.com/) reads *and writes* — variables, nodes, token bindings, everything. These skills require it.

## Install

### Claude Code

```bash
claude plugin marketplace add lifesized/figma-design-sync
claude plugin install figma-design-sync@lifesized
```

Then [set up Figma Console MCP](#figma-console-mcp-setup) if you haven't already.

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

## Quick start

1. [Set up Figma Console MCP](#figma-console-mcp-setup) (one time, 5 min)
2. **(Figma Desktop)** Open your Figma file and navigate to the page you want your design system on
3. **(Figma Desktop)** Open the Desktop Bridge plugin (Plugins → Desktop Bridge) — it connects automatically in local mode
4. **(Claude Code)** Run `/setup-project` to detect your tokens
5. **(Claude Code)** Run `/sync-to-figma` to push everything to Figma

## How it works

**Code → Figma.** Your CSS custom properties and Tailwind classes define the design system. These skills push that into Figma as native variables and component documentation. Every fill, border, and text color is bound to a Figma variable — click any element and you see the token name, not a mystery hex color.

**Flags:**

- `/sync-to-figma` — update existing artboards in-place
- `/sync-to-figma --fresh` — snapshot current page, create a new version (visual git)
- `/sync-to-figma --tokens-only` — variables only, skip artboards
- `/sync-to-figma --component Button` — sync one component

**What gets generated:**

- Color Palette — square swatches bound to variables
- Typography — fonts in context + type scale (auto-detects project fonts, never falls back to Inter)
- Spacing & Radii — visual samples
- Component artboards — one per component, all states (default, hover, focus, active, disabled, loading)

**No design system?** `/setup-project` scans your codebase for scattered colors, font sizes, spacing values, groups near-duplicates, and proposes a consolidated token file. Works with Lovable, v0, Bolt, or any hand-coded project.

## Extending these skills

These use a subset of Figma Console MCP's 59+ tools. Build your own skills with full access to variables, components, nodes, screenshots, accessibility linting, and `figma_execute` (arbitrary Plugin API JavaScript). See [their docs](https://docs.figma-console-mcp.southleft.com/) for the full API.

## Part of a bigger movement

- [Uber's uSpec](https://www.uber.com/en-CA/blog/automate-design-specs/) — agent skills for Figma spec generation, built on Figma Console MCP
- [Romina Kavcic](https://thedesignsystem.guide) — Agentic Design Systems framework (Into Design Systems 2026)
- [Southleft](https://figma-console-mcp.southleft.com/) — the open-source infrastructure layer. [TJ Pitre](https://www.linkedin.com/in/tjpitre/) and team built the foundation that makes all of this possible.

---

## Figma Console MCP setup

One-time setup. Takes about 5 minutes. Two connection modes are available — **local mode is recommended**.

### Local mode (recommended)

Direct connection between the MCP server on your machine and Figma Desktop. No pairing codes, no session expiry, no relay server.

```
Figma Plugin → WebSocket → localhost:9223 → stdio → Claude
```

#### 1. Get a Figma access token

From Figma Desktop: Home → Profile pic (your name, down arrow) → Settings → Security tab → Create new token. Copy it (starts with `figd_`).

#### 2. Add to Claude Code

```bash
claude mcp add figma-console -s user -e FIGMA_ACCESS_TOKEN=figd_YOUR_TOKEN_HERE -- npx -y figma-console-mcp@latest
```

Restart Claude Code.

#### 3. Install the Desktop Bridge plugin

Open any Figma file → Plugins → Search "Desktop Bridge" → Install and run it.

If it doesn't show up, run `npx figma-console-mcp@latest` once in your terminal to generate the plugin files, then import via Plugins → Development → Import plugin from manifest → `~/.figma-console-mcp/plugin/manifest.json`.

That's it — the plugin auto-connects to the local server. Go back to [Quick start](#quick-start).

### Cloud mode

Routes through Southleft's cloud relay. Use this if you can't run the MCP server locally (e.g. Claude Desktop or browser-based agents without stdio support).

```
Figma Plugin → WSS → southleft.com relay → SSE → mcp-remote → Claude
```

```bash
claude mcp add figma-console -s user -- npx -y mcp-remote@latest https://figma-console-mcp.southleft.com/sse
```

Each session requires a 6-character pairing code: tell your agent "connect to Figma", then enter the code in the Desktop Bridge plugin under **Cloud Mode**.

#### Known issues with cloud mode

- **Sessions drop frequently.** The relay connection can break on network blips, idle timeouts, or Claude context switches. Each reconnect requires a new pairing code.
- **Pairing codes expire in 5 minutes.** If you miss the window, you need to generate a new one.
- **`get_status` can report `initialized: false` despite a working connection.** Some tools (`figma_execute`) may work while others (`get_variables`) don't — they use different connection paths.
- **Three network hops.** Each is a failure point: plugin → relay (WebSocket), relay → MCP client (SSE), MCP client → Claude (stdio). Local mode has one hop.

## Found it useful?

Give it a star on GitHub — it helps others find it. If you run into issues or have ideas, [open an issue](https://github.com/lifesized/figma-design-sync/issues).

Built by [lifesized](https://github.com/lifesized).

## License

MIT
