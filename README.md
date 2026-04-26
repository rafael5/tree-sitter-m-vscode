# tree-sitter-m-vscode

VS Code extension for the **M (MUMPS)** programming language. Sibling
to [`tree-sitter-m`](https://github.com/rafael5/tree-sitter-m), the
tree-sitter grammar for M.

## Status

**v0.1 — Two-layer highlighting.** Ships the language declaration
(file extensions `.m` / `.mac` / `.int`), comment / bracket /
indentation rules, a regex-based TextMate grammar for cold-load
rendering, and a `DocumentSemanticTokensProvider` powered by
`tree-sitter-m` compiled to WASM. The TextMate grammar paints the file
the moment it opens; the semantic-tokens layer overlays precise
tree-sitter-driven classification once the parser warms up (a few
dozen ms even on a large routine — see [`tree-sitter-m`'s perf
bench](../tree-sitter-m/docs/build-log.md): 78.6 ms for a 10k-line
synthesised routine).

The provider maps every keyword node our grammar produces — commands,
intrinsic functions, special variables (including Kernel-style vendor
extensions), operators, pattern codes, dot-block prefixes,
postconditionals — onto VS Code's standard semantic-token legend
(`keyword`, `function`, `variable`, `parameter`, `string`, `number`,
`comment`, `operator`) with `defaultLibrary` / `readonly` /
`declaration` modifiers where they apply. Themes that style semantic
tokens get colourised highlighting that matches the parse tree
exactly. Themes that don't fall through to TextMate.

## Why WASM rather than the native Node binding

VS Code extensions can't reliably load native `.node` addons across
every consumer's OS/arch — without prebuilds, users hit a `node-gyp`
build at install time and most don't have a C toolchain. The
`web-tree-sitter` runtime side-steps this entirely: a single `.wasm`
file loads via Emscripten anywhere VS Code runs (desktop and web).

## Building the WASM

`dist/tree-sitter-m.wasm` is **committed** — extension consumers don't
need any build tooling. Maintainers rebuild it from the parser source
whenever `tree-sitter-m`'s grammar changes:

```bash
npm run build-wasm
```

The script (`scripts/build-wasm.sh`) shells out to
`tree-sitter build --wasm --docker`, which pulls Emscripten via
docker. Set `TREE_SITTER_M_REPO=/path/to/tree-sitter-m` if the parser
repo isn't at `~/projects/tree-sitter-m/`.

## Development

```bash
npm install               # web-tree-sitter + dev tooling
npm run compile           # tsc → out/
```

In VS Code, press **F5** (or Run → Start Debugging) to launch a new
Extension Development Host with this extension loaded. Open any `.m`
file and you should see two-layer highlighting per the active theme:
TextMate scopes appear immediately, semantic tokens replace them
within milliseconds of the first parse.

The breadcrumb in the Developer Tools console (Help → Toggle Developer
Tools → Console) confirms activation:

```
tree-sitter-m-vscode: activated.
```

If semantic tokens never appear, check that
`editor.semanticHighlighting.enabled` resolves to `true` for `[m]` —
the extension defaults it on, but the user may have overridden.

## Customizing colors

The extension emits standard VS Code semantic token types (`keyword`,
`function`, `variable`, `parameter`, `string`, `number`, `comment`,
`operator`) with `defaultLibrary` / `readonly` / `declaration`
modifiers where they apply. Colors come from your active theme.

### Out-of-the-box (no setup)

The extension declares `contributes.semanticTokenScopes` in its
manifest, mapping each semantic-token type back to a TextMate scope
(`keyword.control.command.m`, `support.function.intrinsic.m`, etc.)
that virtually every theme already styles. Result: commands appear
distinct from intrinsic functions appear distinct from special
variables under any reasonable theme — Default Dark/Light Modern,
GitHub Dark/Light, One Dark Pro, Dracula, etc.

### Per-theme tuning (optional)

To override or refine, drop into `settings.json`:

```json
"editor.semanticTokenColorCustomizations": {
  "rules": {
    "keyword:m":                          { "foreground": "#C586C0", "bold": true },
    "function.defaultLibrary:m":          { "foreground": "#DCDCAA" },
    "function.declaration:m":             { "foreground": "#4EC9B0", "bold": true },
    "function:m":                         { "foreground": "#DCDCAA" },
    "variable.defaultLibrary.readonly:m": { "foreground": "#4FC1FF", "italic": true },
    "variable:m":                         { "foreground": "#9CDCFE" },
    "parameter.declaration:m":            { "foreground": "#9CDCFE", "italic": true, "bold": true },
    "parameter:m":                        { "foreground": "#9CDCFE", "italic": true },
    "keyword.defaultLibrary:m":           { "foreground": "#CE9178" },
    "operator:m":                         { "foreground": "#D4D4D4" }
  }
}
```

The `:m` suffix on each selector scopes the rule to M files only.
Drop the suffix to apply globally.

To restrict overrides to a specific theme, wrap the rules in a
theme-name key:

```json
"editor.semanticTokenColorCustomizations": {
  "[Default Dark Modern]": {
    "rules": {
      "keyword:m": { "foreground": "#C586C0", "bold": true }
    }
  },
  "[GitHub Light Default]": {
    "rules": {
      "keyword:m": { "foreground": "#CF222E", "bold": true }
    }
  }
}
```

### Inspecting what's happening

Place the cursor on any token and run **Inspect Editor Tokens and
Scopes** from the Command Palette. The hover panel shows:

- **TextMate scopes** — the regex grammar's scope chain.
- **Semantic token type / modifiers** — what our provider emitted.
- **Foreground color** — which rule won and where it came from
  (theme, semantic, or your override).

If a token shows the right semantic type but the wrong color,
override is the answer. If it shows no semantic type at all,
`editor.semanticHighlighting.enabled` is off or the provider didn't
fire on this file (check the language mode in the bottom-right).

## Batch testing a directory of M routines

Three ways, increasing power:

### 1. CLI: open all routines as tabs

```bash
scripts/open-all.sh                          # default: test-routines/, max 50 tabs
scripts/open-all.sh ~/vista-meta/Packages    # walk a real corpus
scripts/open-all.sh test-routines 200        # raise the cap
scripts/open-all.sh test-routines all        # no cap (careful with large corpora)
```

Opens the directory as a workspace, then opens every `.m` / `.mac` /
`.int` file under it as a separate tab. Click through the tabs to
verify highlighting visually.

### 2. Extension command: open all M files in this workspace

Open a folder in VS Code (File → Open Folder…), then Command Palette
(Ctrl/Cmd+Shift+P) → **M (MUMPS): Open all M files in workspace as
tabs**. Capped at 200 to keep VS Code responsive.

### 3. Extension command: smoke-report all M files in this workspace

Command Palette → **M (MUMPS): Smoke-report all M files in
workspace**. Parses every `.m` / `.mac` / `.int` file under the
workspace via the same WASM parser the highlighter uses, then opens
an Output panel listing:

- Clean / total file count and percentage.
- Total bytes parsed + throughput.
- Every file with a parse error, plus the first ERROR / MISSING
  line so you can jump straight to the problem.

Capped at 5,000 files per run. Perfect for pointing at the VistA
corpus and confirming that any visual highlighting issue you see is
*not* a parse failure (or, conversely, finding the routine that the
grammar still chokes on).

## Packaging and publishing

```bash
npm run package           # produces tree-sitter-m-vscode-0.1.0.vsix
vsce publish              # marketplace push (requires vsce login)
```

`vsce login` requires a Personal Access Token from
https://dev.azure.com/<org>/_usersSettings/tokens — see
[VS Code's publishing guide](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
for the dance.

## License

AGPL-3.0-only. See [`LICENSE`](LICENSE).

Matches the `tree-sitter-m` parser and the rest of the project family
(`m-standard`, the future `tree-sitter-m-lint`, etc.).
