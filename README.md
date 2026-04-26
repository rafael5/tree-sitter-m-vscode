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
