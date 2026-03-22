---
name: sync-from-figma
description: Read Figma variables and diff against CSS tokens. Activate with "/sync-from-figma". Supports --dry-run. Reads variable collections, compares to canonical CSS custom properties, generates updated CSS.
allowed-tools: Read, Grep, Glob, Bash, Edit, mcp__figma-console__figma_get_status, mcp__figma-console-local__figma_get_status, mcp__figma-console__figma_reconnect, mcp__figma-console-local__figma_reconnect, mcp__figma-console__figma_get_variables, mcp__figma-console-local__figma_get_variables, mcp__figma-console__figma_get_token_values, mcp__figma-console-local__figma_get_token_values, mcp__figma-console__figma_browse_tokens, mcp__figma-console-local__figma_browse_tokens, mcp__figma-console__figma_list_open_files, mcp__figma-console-local__figma_list_open_files
---

# Sync from Figma (Global)

Read design token variables from Figma and diff against CSS custom properties. Generate updated CSS.

## Prerequisites

- Console MCP or Remote MCP connected to Figma
- CSS file with `:root` custom properties as the canonical source

## Workflow

1. **Verify connection:** `figma_get_status`
2. **Read Figma variables:** `figma_get_variables` — filter to the relevant collection
3. **Read CSS tokens:** Parse the canonical CSS file's `:root` block
4. **Map names:** Convert Figma paths back to CSS variable names
   - `colors/bg` → `--bg`
   - `spacing/sm` → `--space-sm`
   - `radii/lg` → `--radius-lg`
5. **Convert values:**
   - COLOR `{r,g,b,a}` → hex `#rrggbb` (if a=1) or `rgba(r,g,b,a)`
   - FLOAT → append `px`
   - STRING → direct
6. **Diff:** Categorize as Added / Modified / Removed / Unchanged
7. **Report:** Show diff summary
8. **Apply** (unless `--dry-run`): Edit CSS file preserving comment structure

## Flags

- `--dry-run` — Show diff only (DEFAULT — always dry-run first)
- `--force` — Apply without confirmation

## Token Integrity

When reading from Figma, only trust values that are bound to Figma variables (not raw fills). If a node has raw color fills without variable bindings, flag it as "unbound" in the diff report — these are likely manually edited values that drifted from the token system. The canonical values are the ones stored as Figma variables, not what's painted on artboard swatches.

## If this project has a skill reference file

Check for `.agents/skills/sync-from-figma/SKILL.md` — if it exists, read it first for project-specific collection names and mapping tables.
