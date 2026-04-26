# tree-sitter-m-vscode

VS Code extension for the **M (MUMPS)** programming language. Sibling
to [`tree-sitter-m`](https://github.com/rafael5/tree-sitter-m), the
tree-sitter grammar for M.

## Status

**v0.1 — Phase 1 (TextMate-based highlighting).** Ships the language
declaration (file extensions `.m` / `.mac` / `.int`), comment / bracket
/ indentation rules, and a regex-based TextMate grammar covering the
M tokens that VS Code needs to render M source meaningfully out of the
box. Activates `editor.semanticHighlighting.enabled` for M files so the
Phase 2 layer light-switches on automatically once it's wired.

**v0.2 (planned, post `tree-sitter-m@0.1.0` npm publish).** Add a
`DocumentSemanticTokensProvider` powered by `tree-sitter-m` compiled to
WASM via `tree-sitter build --wasm`. Semantic tokens overlay the
TextMate grammar's base tokenization with precise tree-sitter-driven
classification (commands, intrinsic functions, special variables,
operators, pattern codes, indirection, postconditionals, dot-block
prefixes — all the things our grammar already distinguishes). The
TextMate grammar stays as the cold-load fallback during the first
parse pass.

The Phase 2 sketch lives in [`src/extension.ts`](src/extension.ts) as
commented code so the wiring shape is reviewable before it's enabled.

## Why two phases

VS Code's tree-sitter syntax-highlighting API is still partly internal
(Microsoft uses it for their bundled languages but the public surface
is incremental). The `DocumentSemanticTokensProvider` route is the
publicly stable API and works today — but it requires a parser that
runs in the extension host, which means either:

1. A native Node binding (`tree-sitter` + `tree-sitter-m` from npm),
   which needs prebuilt binaries for every consumer's OS/arch — or
   they'll hit a `node-gyp` build at install time and most users
   won't have a C toolchain handy.
2. The `web-tree-sitter` runtime, a single .wasm file that loads
   everywhere VS Code runs.

Phase 2 will use option 2. Building the `.wasm` from `tree-sitter-m`'s
`src/parser.c` requires emscripten, so the workflow is:

```bash
# in tree-sitter-m's repo:
tree-sitter build --wasm
cp tree-sitter-m.wasm ../tree-sitter-m-vscode/dist/
```

This is the work that follows the `tree-sitter-m` v0.1 npm publish.

## Development

```bash
npm install
npm run compile           # tsc → out/
```

In VS Code, press **F5** (or Run → Start Debugging) to launch a new
Extension Development Host with this extension loaded. Open any `.m`
file and you should see syntax highlighting per the active theme.

The breadcrumb in the Developer Tools console (Help → Toggle Developer
Tools → Console) confirms the extension activated:

```
tree-sitter-m-vscode: activated. Phase 1 — TextMate grammar only.
```

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
