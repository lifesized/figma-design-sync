# Figma Console MCP — Quick Setup Reference

## Prerequisites

- Figma Desktop app (not browser)
- Figma Console MCP server installed in Claude Code
- Desktop Bridge plugin installed in Figma

## Pairing (every session)

1. Run `figma_pair_plugin` — get a 6-character code (expires in 5 min)
2. In Figma Desktop: open Desktop Bridge plugin → toggle "Cloud Mode" → enter code → Connect
3. Verify with `figma_get_status` — should show `initialized: true`

## If pairing fails

- Code expired → generate a new one
- `get_status` shows `initialized: false` → try `figma_execute` instead (it uses a different connection path)
- Variables REST API returns 403 → enterprise plan required, use console fallback (`useConsoleFallback: true`)

## Common gotchas

### Variable bindings on fills
```javascript
// WRONG — setBoundVariable doesn't work on fills
node.setBoundVariable('fills', 0, variable);

// CORRECT — use the paint-specific API
const paint = figma.variables.setBoundVariableForPaint(fills[0], 'color', variable);
node.fills = [paint];
```

### Reading variables
```javascript
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const variable = await figma.variables.getVariableByIdAsync(varId);
const value = variable.valuesByMode[modeId];
```

### Checking if fills are bound
```javascript
const boundVars = node.boundVariables || {};
const hasFillBinding = !!(boundVars.fills && boundVars.fills.length > 0);
```

## MCP tool preferences

| Task | Tool | Notes |
|------|------|-------|
| Read variables | `figma_get_variables` | Falls back to console extraction on 403 |
| Create/modify nodes | `figma_execute` | Full plugin API access, most flexible |
| Screenshots | `figma_capture_screenshot` | Use for verification after creating |
| Pair plugin | `figma_pair_plugin` | Generates 6-char code, 5 min expiry |
| Check connection | `figma_get_status` | Shows if bridge is connected |
