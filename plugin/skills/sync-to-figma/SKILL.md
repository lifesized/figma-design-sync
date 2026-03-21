---
name: sync-to-figma
description: Push design tokens and components from code to Figma via Console MCP. Activate with "/sync-to-figma". Updates existing design system in-place by default. Use "--fresh" to create a new versioned page (visual git). Use "--tokens-only" to skip artboards.
allowed-tools: Read, Grep, Glob, Bash, Edit, AskUserQuestion, mcp__figma-console__figma_get_status, mcp__figma-console__figma_reconnect, mcp__figma-console__figma_setup_design_tokens, mcp__figma-console__figma_batch_create_variables, mcp__figma-console__figma_batch_update_variables, mcp__figma-console__figma_create_child, mcp__figma-console__figma_create_variable, mcp__figma-console__figma_create_variable_collection, mcp__figma-console__figma_set_fills, mcp__figma-console__figma_set_strokes, mcp__figma-console__figma_set_text, mcp__figma-console__figma_resize_node, mcp__figma-console__figma_move_node, mcp__figma-console__figma_rename_node, mcp__figma-console__figma_take_screenshot, mcp__figma-console__figma_capture_screenshot, mcp__figma-console__figma_get_selection, mcp__figma-console__figma_navigate, mcp__figma-console__figma_execute, mcp__figma-console__figma_get_variables, mcp__figma-console__figma_list_open_files, mcp__figma-console__figma_delete_node
---

# Sync to Figma (Global)

Push design tokens and UI components from code into Figma as native variables and components.

## Source of Truth

**Code is the single source of truth.** CSS custom properties and Tailwind classes define the design system. Figma is a mirror — this skill pushes code → Figma, never the reverse. `sync-from-figma` exists only as a drift audit tool.

## Modes & Flags

| Flag | Effect |
|------|--------|
| (none) | **Update in-place.** Variables match by name. Artboards found by name in existing section — children cleared and rebuilt (preserves canvas position). |
| `--fresh` | **New version (visual git commit).** Variables update in-place. Current working page is snapshot-renamed with date (e.g. "Design System — 2026-03-21"). New working page created with fresh artboards bound to live variables. Archived page is frozen history. |
| `--tokens-only` | Update variables only, skip artboards. |

## CRITICAL RULES

1. **Always ask before creating components.** Present the detected list with states. Let the user confirm.
2. **Separate artboards:** Color Palette, Typography, Spacing & Radii, one per component type, Composition mockup.
3. **All states per component.** Grid: variants (rows) x states (columns) — default, hover, focus, active, disabled, loading.
4. **Typography artboard:** Show both fonts in realistic UI contexts (not just specimens). Include names, descriptions, tag labels, button text. Plus a full type scale with role annotations.
5. **Composition mockup:** Ask which app view to assemble. Build at mobile width using real component instances and placeholder content.
6. **Screenshot each artboard** individually for verification (max 3 iterations).

## ATOMIC DESIGN — TOKEN BINDING RULES

Every visual property in Figma MUST be bound to a Figma variable, not raw colors/values. This is the atomic design principle — tokens are the single source of truth.

### Colors
- **All color fills** on swatches, component backgrounds, borders, and text must use `setBoundVariableForPaint(paint, 'color', variable)` to bind to a Figma variable — never set raw hex/rgba.
- **Color palette swatches** must be **square** (cornerRadius: 0), not rounded.
- If a token doesn't exist yet, create the variable first, then bind.

### Spacing & Typography
- **Spacing values** (padding, gaps, heights) should bind to FLOAT variables via `node.setBoundVariable('width', variable)` / `setBoundVariable('height', variable)` etc.
- **Font sizes** should bind to FLOAT variables where Figma supports it.
- **Corner radii** should bind to radius variables via `setBoundVariable('topLeftRadius', variable)` etc.

### Component Artboards
- Component state representations must use token-bound fills, not raw colors. E.g. a button's `bg-white/15` should bind to `color/white-15`, borders to `color/border`, text to `color/text`.
- **Artboard backgrounds** for dark-theme projects must use a visible surface color (e.g. `color/panel` or `color/panel-2`) so components aren't invisible against the artboard.

### General
- After creating variables AND visual nodes, always verify bindings with `node.boundVariables` — if fills show `hasFillBinding: false`, the binding was missed.
- When updating existing artboards, preserve variable bindings — don't overwrite bound fills with raw colors.

## Workflow

### Step 0: Find or create target

**Default mode (update in-place):**
1. Search for an existing section named "Design System" (or project-specific name) on the current page
2. If found: use it — artboards inside will be updated by name match
3. If not found: create the section

**`--fresh` mode (visual git commit):**
1. Find the current working page with the design system section
2. Rename it with a date stamp (e.g. "Design System — 2026-03-21")
3. Create a new page as the working page
4. Create a fresh "Design System" section on it
5. Old page is now frozen history — its artboards keep whatever fills they had at snapshot time

### Steps 1–10: Build

1. **Verify connection:** `figma_get_status`
2. **Extract + push tokens** — idempotent: match variables by name in the collection, create missing ones, update changed values. One collection forever, never duplicate.
3. **Color Palette artboard:** Swatches grouped by category (Backgrounds, Text, Brand, Semantic). All bound to variables. Square corners.
4. **Typography artboard:** Both fonts in context, type scale with sizes and roles
5. **Spacing & Radii artboard:** Visual bars + rounded rectangle samples
6. **ASK the user:** Component list with states — confirm before creating
7. **Component artboards:** One per type, all states in variant x state grid. Token-bound fills.
8. **ASK the user:** Which app view to mock up
9. **Composition artboard:** Realistic mobile-width view assembling all components
10. **Verify:** Screenshot per artboard → analyze → fix

### Update-in-place strategy (default mode)

When updating existing artboards:
1. Find the artboard by name inside the design system section
2. If found: clear its children and rebuild contents (preserves the artboard's position/size on canvas)
3. If not found: create a new artboard in the section
4. Variables are always matched by name — never create duplicates
5. After rebuild, verify token bindings on all fills

### Visual git model (`--fresh` mode)

The mental model:
- **Variables = `main`** — one collection, always current, this is HEAD
- **Current working page = working tree** — artboards bound to live variables, auto-updates when tokens change
- **Archived pages = commits** — frozen snapshots, browsable for comparison, no live bindings needed

## State Representation in Figma

| State | Visual treatment |
|-------|-----------------|
| default | Base component |
| hover | Apply hover CSS (border-color, bg shift, elevation) |
| focus | Add 2px ring/outline |
| active | Slightly pressed (darker fill or scale) |
| disabled | 40% opacity, desaturated |
| loading | Skeleton pulse or spinner placeholder |

## Read Before Write

Before creating or updating any artboard, read the existing Figma state first:
1. Check if the design system section exists on the current page
2. List existing artboards by name within it
3. For each artboard to update: read its children to understand current structure
4. This enables smart diffing — only rebuild what changed, preserve manual edits where possible

## Component-Level Sync

Support `--component <name>` flag to sync a single component's artboard instead of the full system. Useful when iterating on one component. Still updates variables (they're shared), but only touches the named artboard.

## Future: Props/API Documentation

When generating component artboards, consider adding a props table section showing:
- Prop name, type, default value
- Variant axes with instance previews
- Slot/children documentation
This makes the Figma output useful as engineering reference, not just visual states.

## If this project has a skill reference file

Check for `.agents/skills/sync-to-figma/SKILL.md` — read it first for project-specific mappings.
