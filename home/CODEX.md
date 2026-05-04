# Codex Agent Guide

## Table Rendering (Node.js/JavaScript)

Always use `cli-table3` for structured tables:

```javascript
const Table = require('cli-table3');

const table = new Table({
  head: ['Col1', 'Col2', 'Col3'].map(h => '\x1b[36m' + h + '\x1b[0m'),
  style: { head: [], border: ['cyan'], 'padding-left': 1, 'padding-right': 1 },
  wordWrap: true,
  colWidths: [25, 20, 15]
});

data.forEach(row => table.push(Object.values(row)));
console.log(table.toString());
```

**Rules:**
- Headers: cyan (`\x1b[36m`)
- Numbers: right-align
- Text: left-align
- Currency: `$X,XXX.XX` format
- Negative values: red (`\x1b[31m`)
- Totals: bold+yellow (`\x1b[1m\x1b[33m`)
- Always set explicit `colWidths`
- Use `wordWrap: true`
- Include row counts and totals
- Max width: 120 chars

## Package Managers

- JavaScript/TypeScript: Use `pnpm` only (via corepack)
- Python: Use `uv` only

## CLIs

Prefer: `rg` > grep, `fd` > find, `eza` > ls, `delta` for diffs, `gh` for GitHub, `just` for task runners