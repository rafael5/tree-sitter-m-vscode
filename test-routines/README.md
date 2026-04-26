# test-routines

A series of M routines, each focused on one syntactic category, so
you can verify the **tree-sitter-m-vscode** plug-in is highlighting
each construct the way the parser sees it.

Open any file in VS Code with the extension active. Two layers of
highlighting will paint the file in sequence:

1. **TextMate grammar** (regex-based, ships in
   `syntaxes/m.tmLanguage.json`) — paints in &lt;50 ms. Approximate.
2. **Semantic tokens** (tree-sitter-m via WASM) — overlays within a
   few dozen ms more. Precise. This is the layer this readme
   documents.

Themes that don't style semantic tokens distinctly from TextMate
scopes will look identical for both layers. Most modern themes
(Dark Modern, Light Modern, GitHub themes) do distinguish — pick one
of those if you want to see the difference.

To inspect a specific token's classification: place the cursor on it,
Command Palette → **Inspect Editor Tokens and Scopes**. The
"semantic token type" row should populate.

## Files

| File | Exercises |
|---|---|
| [`01-commands.m`](01-commands.m) | Every command keyword in the union grammar — ANSI canonicals, IRIS-only commands, ANSI-but-rare ones, all 33 vendor `Z*` commands. |
| [`02-functions-isvs.m`](02-functions-isvs.m) | Intrinsic functions (string, math, list, system) and intrinsic special variables — both canonical (`$EXTRACT`, `$HOROLOG`) and the abbreviated prefix forms (`$E`, `$H`). |
| [`03-operators-numbers-strings.m`](03-operators-numbers-strings.m) | Every M operator — 17 base + 8 negated compounds + 3 YDB shorthands. Number formats (int / decimal / leading-dot / exponent). String literal with `""` escape. |
| [`04-patterns-postcond-dotblocks.m`](04-patterns-postcond-dotblocks.m) | Pattern matching (codes A C E L N P U, multi-letter pattern codes, alternation, negation, indirection in pattern). Postconditionals (command-level + per-arg). Dot blocks (single, nested, multi-level). |
| [`05-indirection-extrinsic-globals.m`](05-indirection-extrinsic-globals.m) | Indirection (`@expr`, `@expr@(subs)`, nested `@@`). Globals (subscripted, naked, system). Extrinsic calls (every `$$LBL[^RTN][(args)]` form). Numeric local-label call (`D 12(arg)`). Format control (`!`, `#`, `?N`, `*N`). |
| [`06-formals-byref-vendor.m`](06-formals-byref-vendor.m) | Formal parameter declarations on labels. Pass-by-reference (`.VAR` and `.VAR(subs)`). Kernel-style vendor special-variable extensions (`$PD`, `$PT`). |
| [`07-real-vista-kernel.m`](07-real-vista-kernel.m) | Kitchen-sink VistA Kernel-style routine that mixes everything. Use as the "if this looks right, the plug-in is working" check. |

## Expected semantic-token mapping

This is the source-of-truth for what the provider emits. If a token
in any file isn't picking up the expected scope, it's a bug in
`src/extension.ts`'s rule tables.

| Construct in M | Tree-sitter node type | Semantic token (modifiers) |
|---|---|---|
| `BREAK`, `S`, `WRITE`, `FOR`, `ZWRITE`, ... | `command_keyword` | `keyword` |
| `$EXTRACT`, `$LENGTH`, `$ZCONVERT`, `$E`, ... | `intrinsic_function_keyword` | `function` (defaultLibrary) |
| `$X`, `$Y`, `$HOROLOG`, `$ZJOB`, ... | `special_variable_keyword` | `variable` (defaultLibrary, readonly) |
| `$PD`, `$PT` (Kernel vendor SVs) | `vendor_sv_extension` | `variable` (defaultLibrary, readonly) |
| Pattern letters in `?3U2L1N` | `pattern_letter` | `keyword` (defaultLibrary) |
| Operators `=`, `+`, `'=`, `>=`, `_`, `[`, ... | `operator` | `operator` |
| `!`, `#`, `*N` in WRITE | `format_control` | `operator` |
| `?N` (tab-to-column) in WRITE | `format_tab` | `operator` |
| Leading `.` / `..` of dot-block lines | `dot_block_prefix` | `operator` |
| `^GBL`, `^GBL(...)`, `^("...")`, `^$JOB` | `global_variable` | `variable` |
| `D 12(args)` numeric label call | `numeric_label_call` | `function` |
| Routine label at column 0 | child `label` of `line` | `function` (declaration) |
| Identifier in `local_variable` | child `identifier` | `variable` |
| Identifier / number in `extrinsic_function` | child | `function` |
| Identifier / number in `entry_reference` | child | `function` |
| Identifier in `by_reference` (`.VAR`) | child `identifier` | `parameter` |
| Identifier in `formals` (`(A,B)` after label) | child `identifier` | `parameter` (declaration) |
| `:` in `postconditional` / `argument_postconditional` | child `:` | `keyword` |
| `";comment to EOL"` | `comment` | `comment` |
| `"string"` | `string` | `string` |
| `42`, `3.14`, `.5`, `1E10` | `number` | `number` |

## Smoke-parse all files

To confirm every routine parses cleanly with no `ERROR` nodes (a
necessary precondition for the highlighting to be correct):

```bash
cd ~/projects/tree-sitter-m-vscode
node -e '
const { Parser, Language } = require("web-tree-sitter");
const fs = require("fs"), path = require("path");
(async () => {
  await Parser.init();
  const lang = await Language.load("dist/tree-sitter-m.wasm");
  const p = new Parser(); p.setLanguage(lang);
  for (const f of fs.readdirSync("test-routines").filter(x => x.endsWith(".m")).sort()) {
    const src = fs.readFileSync("test-routines/"+f, "utf-8");
    const t = p.parse(src);
    console.log((t.rootNode.hasError ? "FAIL " : "ok   ") + f);
  }
})();
'
```

Every file should print `ok`. If any prints `FAIL`, that file has a
construct the parser can't currently handle — either a real bug, or
a known scope-locked-out construct (like ObjectScript) that
shouldn't be in test routines anyway.

## Known limitations surfaced while authoring these routines

Three findings turned up while drafting the test corpus. All three
are formally logged in
[`tree-sitter-m/docs/discoveries.md`](https://github.com/rafael5/tree-sitter-m/blob/main/docs/discoveries.md);
the upstream-actionable one is also on m-standard's
[`docs/build-log.md` BL-014](https://github.com/rafael5/m-standard/blob/main/docs/build-log.md#bl-014).
Summarised here so test-routine authors don't trip on them again:

- **[DISC-001](https://github.com/rafael5/tree-sitter-m/blob/main/docs/discoveries.md#disc-001)** —
  YDB/IRIS list-function 2-letter abbreviations (`$LB`, `$LI`,
  `$LL`, etc.) aren't in `m-standard/integrated/grammar-surface.json`
  yet, so they parse as ERROR. Use canonical full names
  (`$LISTBUILD`, `$LISTGET`, `$LISTLENGTH`) until the upstream fix
  ships.
- **[DISC-002](https://github.com/rafael5/tree-sitter-m/blob/main/docs/discoveries.md#disc-002)** —
  The negated compound operators `'[`, `']`, `']]` lex as a single
  token only when there's no whitespace between the operator and
  the right-hand side. Write `S1'["z"`, not `S1'[ "z"`. Real M is
  written without operator spacing, so this is rarely an issue
  outside hand-typed test fixtures.
- **[DISC-003](https://github.com/rafael5/tree-sitter-m/blob/main/docs/discoveries.md#disc-003)** —
  By-reference (`.VAR`) doesn't accept globals (`.^GBL`). Globals
  in M are already by-name, so the construct is semantically
  meaningless; don't write it. Pass `.@NAME` (indirection) for the
  general case.
