# M (MUMPS) — VS Code Language Support

Syntax highlighting and language tooling for the **M (MUMPS)**
programming language, powered by the
[`tree-sitter-m`](https://github.com/m-dev-tools/tree-sitter-m) grammar
compiled to WASM.

Recognises `.m`, `.mac`, and `.int` files. Works on VS Code Desktop
and VS Code for the Web.

---

## Contents

- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Commands](#commands)
- [Customising colours](#customising-colours)
- [Batch testing a directory of routines](#batch-testing-a-directory-of-routines)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [How it works](#how-it-works)
- [Related projects](#related-projects)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Two-layer syntax highlighting.** A TextMate grammar paints the
  file the moment it opens; a `DocumentSemanticTokensProvider` driven
  by `tree-sitter-m` overlays precise, parse-tree-accurate
  classification within milliseconds of the first parse.
- **Comprehensive token coverage.** Commands, intrinsic functions,
  special variables (including Kernel-style vendor extensions),
  operators, pattern codes, dot-block prefixes, postconditionals,
  formal-parameter declarations, and references — all mapped onto
  VS Code's standard semantic-token legend so any decent theme
  colours them correctly out of the box.
- **Language services.** File-extension registration, comment
  toggling, bracket / auto-closing pairs, indentation rules.
- **Workspace-wide smoke testing.** A built-in command parses every
  M file in the open workspace and reports parse errors with
  jump-to-line precision — handy for validating the grammar against
  a real corpus (e.g. VistA, OpenEHR, YottaDB).
- **Cross-platform via WASM.** No `node-gyp`, no native binaries,
  no per-arch builds — runs anywhere VS Code does.

## Installation

### From the VS Code Marketplace

1. Open the **Extensions** view (`Ctrl+Shift+X` / `Cmd+Shift+X`).
2. Search for **`M MUMPS`** or **`tree-sitter-m`**.
3. Click **Install** on *M (MUMPS)* by `rafael5`.

### From a `.vsix` file

```bash
code --install-extension tree-sitter-m-vscode-<version>.vsix
```

### From source

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Quick start

1. Install the extension.
2. Open any `.m`, `.mac`, or `.int` file. The status-bar language
   indicator at the bottom-right should read **`M`**.
3. Highlighting appears immediately. Within ~50 ms (first file after
   activation) the semantic-token layer overlays the TextMate paint
   with parse-tree-driven colours.

That's it. No configuration is required.

## Commands

All commands are available in the Command Palette
(`Ctrl+Shift+P` / `Cmd+Shift+P`). Type "MUMPS" to filter.

| Command                                                  | Description                                                                                  |
| ---                                                      | ---                                                                                          |
| `M (MUMPS): About this extension`                        | Shows version and a one-line description.                                                    |
| `M (MUMPS): Open all M files in workspace as tabs`       | Opens every `.m` / `.mac` / `.int` file under the workspace as a tab. Capped at 200.         |
| `M (MUMPS): Smoke-report all M files in workspace`       | Parses every M file and produces an Output-panel report of parse errors and throughput stats.|

## Customising colours

The extension emits standard VS Code semantic-token types
(`keyword`, `function`, `variable`, `parameter`, `string`, `number`,
`comment`, `operator`) with `defaultLibrary` / `readonly` /
`declaration` modifiers where they apply. Colours come from your
active theme.

### Out of the box

The extension declares `contributes.semanticTokenScopes` mapping each
semantic-token type back to a TextMate scope
(`keyword.control.command.m`, `support.function.intrinsic.m`,
`variable.parameter.declaration.m`, etc.) that virtually every theme
already styles. Result: commands look distinct from intrinsic
functions look distinct from special variables under any reasonable
theme — Default Dark/Light Modern, GitHub Dark/Light, One Dark Pro,
Dracula, Monokai, Solarized.

### Per-token overrides

To refine specific tokens, drop into `settings.json`:

```jsonc
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

### Per-theme overrides

Wrap the rules in a theme-name key to limit them to a specific
theme:

```jsonc
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
- **Semantic token type / modifiers** — what the provider emitted.
- **Foreground colour** — which rule won and where it came from
  (theme rule, semantic rule, or your override).

## Batch testing a directory of routines

Three workflows, increasing in power:

### 1. CLI: open all routines as tabs

```bash
scripts/open-all.sh                          # default: test-routines/, max 50 tabs
scripts/open-all.sh /path/to/some/Packages   # walk a real corpus (e.g. m-modern-corpus)
scripts/open-all.sh test-routines 200        # raise the cap
scripts/open-all.sh test-routines all        # no cap (careful with large corpora)
```

Opens the directory as a workspace, then opens every `.m` / `.mac` /
`.int` file under it as a separate tab. Click through to verify
highlighting visually.

### 2. Extension command: open all M files in this workspace

Open a folder in VS Code (File → Open Folder…), then Command Palette
→ **M (MUMPS): Open all M files in workspace as tabs**. Capped at 200
tabs to keep VS Code responsive.

### 3. Extension command: smoke-report all M files in this workspace

Command Palette → **M (MUMPS): Smoke-report all M files in
workspace**. Parses every `.m` / `.mac` / `.int` file under the
workspace via the same WASM parser the highlighter uses, then opens
an Output panel listing:

- Clean / total file count and percentage.
- Total bytes parsed and throughput (MB/s).
- Every file with a parse error, plus the first ERROR / MISSING
  line so you can jump straight to the problem.

Capped at 5,000 files per run. Useful for pointing at the VistA
corpus (or any large M codebase) and confirming that any visual
highlighting issue you see is *not* a parse failure — or, conversely,
finding the routine that the grammar still chokes on.

## Configuration

The extension contributes the following editor defaults for `[m]`
files (set via `contributes.configurationDefaults` — the user can
override any of them in `settings.json`):

| Setting                                | Default | Why                                                                |
| ---                                    | ---     | ---                                                                |
| `editor.tabSize`                       | `1`     | M routines conventionally indent one space per dot-block level.    |
| `editor.insertSpaces`                  | `true`  | Spaces, not tabs.                                                  |
| `editor.detectIndentation`             | `false` | Auto-detection often guesses wrong on M and disables the default.  |
| `editor.semanticHighlighting.enabled`  | `true`  | Required for the parse-tree-accurate token layer to render.        |

The extension itself exposes no contributed settings (no
`contributes.configuration`) — colour tuning lives in the standard
`editor.semanticTokenColorCustomizations` API documented above.

## Troubleshooting

### Semantic tokens never appear (only TextMate colours)

Run **Inspect Editor Tokens and Scopes** from the Command Palette on
any token. If the **semantic token type** row is empty, semantic
highlighting is disabled. Check:

1. The language mode in the bottom-right reads **`M`**. If not, the
   provider isn't activated. Click the language indicator and pick
   **M** manually, or check `files.associations` for a conflicting
   entry.
2. `editor.semanticHighlighting.enabled` is `true` for `[m]`. The
   extension defaults it on, but a user-level override can disable
   it. Look in your `settings.json` for `"[m]": { ... }` blocks.
3. Open the Developer Tools console (Help → Toggle Developer Tools)
   and look for the activation breadcrumb:
   ```
   tree-sitter-m-vscode: activated.
   ```
   If you don't see it, the WASM parser failed to load — the console
   will show the underlying error.

### A token has the right semantic type but the wrong colour

Add an override under `editor.semanticTokenColorCustomizations` —
see [Customising colours](#customising-colours).

### A construct is mis-parsed (wrong syntax tree, ERROR nodes appear)

That's a grammar issue, not an extension issue. File against
[`tree-sitter-m`](https://github.com/m-dev-tools/tree-sitter-m/issues)
with a minimal reproducing routine. The smoke-report command makes
finding such routines straightforward.

### Performance feels slow on large routines

The parser runs synchronously on the first parse, then incrementally
on subsequent edits. The `tree-sitter-m` benchmark parses a 10k-line
synthesised routine in ~80 ms cold. If you're seeing seconds rather
than tens of milliseconds, please file an issue with a profile and
the routine size.

## How it works

The extension ships two highlighting layers:

1. **TextMate grammar** ([`syntaxes/m.tmLanguage.json`](syntaxes/m.tmLanguage.json)).
   A regex-based grammar that produces immediate, no-warmup-required
   highlighting the moment a file is opened. Themes that don't style
   semantic tokens get this layer only.
2. **Semantic-tokens overlay** (`DocumentSemanticTokensProvider` in
   [`src/extension.ts`](src/extension.ts)). After the WASM parser
   loads, every keyword/identifier/literal node is mapped onto VS
   Code's semantic-token legend with appropriate modifiers. Themes
   that style semantic tokens override the TextMate paint with this
   precise, parse-tree-driven classification.

The WASM file (`dist/tree-sitter-m.wasm`) is the
[`tree-sitter-m`](https://github.com/m-dev-tools/tree-sitter-m) grammar
compiled to WebAssembly via Emscripten. Using WASM rather than the
native Node binding avoids `node-gyp` install-time builds and works
identically on Linux, macOS, Windows, and VS Code for the Web.

For build/release details see [CONTRIBUTING.md](CONTRIBUTING.md).

## Related projects

- **[`tree-sitter-m`](https://github.com/m-dev-tools/tree-sitter-m)** —
  the tree-sitter grammar this extension consumes.
- **[`m-standard`](https://github.com/m-dev-tools/m-standard)** — the
  citable, machine-readable reference for the M language as recognised
  by this family of tools (commands / ISVs / functions / pragmatic +
  SAC + operational tier classifications).
- **[`m-cli`](https://github.com/m-dev-tools/m-cli)** — the
  source-level toolchain: `m fmt` / `m lint` / `m test` /
  `m coverage` / `m doc`. The companion `m lsp` Language Server is
  spawned by this extension when m-cli is installed.
- **[`m-stdlib-vscode`](https://github.com/m-dev-tools/m-stdlib-vscode)** —
  manifest-driven hover / goto-def / completion for `m-stdlib`'s
  `STD*` symbols. Install both for the full editor experience.

## Contributing

Bug reports, parse-tree gripes, and pull requests are all welcome.
See [CONTRIBUTING.md](CONTRIBUTING.md) for build, test, and release
workflows.

## License

[AGPL-3.0-only](LICENSE). Matches the licensing of `tree-sitter-m`
and the rest of the project family.
