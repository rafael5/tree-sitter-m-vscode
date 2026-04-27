# Contributing

Thanks for considering a contribution. This document covers the
development, packaging, and release workflows for
`tree-sitter-m-vscode`.

## Repository layout

```
├── src/                       TypeScript source for the extension
├── syntaxes/                  TextMate grammar (m.tmLanguage.json)
├── language-configuration.json   Comments, brackets, indentation rules
├── dist/                      tree-sitter-m.wasm (committed)
├── scripts/                   Build & batch-test helpers
│   ├── build-wasm.sh          Rebuilds dist/tree-sitter-m.wasm
│   └── open-all.sh            Opens a directory of .m files as tabs
├── test-routines/             Curated M routines for visual QA
├── out/                       Compiled JavaScript (gitignored)
└── package.json               Extension manifest
```

## Prerequisites

- **Node.js** ≥ 18
- **VS Code** ≥ 1.85
- **docker** — only required for rebuilding the WASM grammar

## Development loop

```bash
npm install                   # web-tree-sitter + dev tooling
npm run compile               # tsc → out/
```

In VS Code, press **F5** (or **Run → Start Debugging**) to launch a
new Extension Development Host with this extension loaded. Open any
`.m` file and you should see two-layer highlighting per the active
theme: TextMate scopes appear immediately, semantic tokens replace
them within a few dozen milliseconds of the first parse.

The Developer Tools console (Help → Toggle Developer Tools) shows
the activation breadcrumb:

```
tree-sitter-m-vscode: activated.
```

`npm run watch` keeps the TypeScript compiler running in the
background — useful while iterating.

## Rebuilding the WASM

`dist/tree-sitter-m.wasm` is committed so end users (and CI) never
need a build toolchain. Rebuild it whenever
[`tree-sitter-m`](https://github.com/rafael5/tree-sitter-m)'s grammar
changes:

```bash
npm run build-wasm
```

This shells out to `scripts/build-wasm.sh`, which runs
`tree-sitter build --wasm --docker` against the parser source.
The script expects the parser repo at `~/projects/tree-sitter-m/` —
override with `TREE_SITTER_M_REPO=/path/to/tree-sitter-m` if it
lives elsewhere.

## Packaging

```bash
npm run package
# → tree-sitter-m-vscode-<version>.vsix
```

Use the resulting `.vsix` to install locally with
`code --install-extension <file>` or to attach to a GitHub release.

## Publishing to the Marketplace

The extension is published under the `rafael5` publisher account.

1. Create a Personal Access Token at
   `https://dev.azure.com/<org>/_usersSettings/tokens`. Required
   scopes: **Marketplace → Manage**. Set expiry as you prefer.
2. Authenticate `vsce` (one-off):
   ```bash
   npx vsce login rafael5
   # paste PAT when prompted
   ```
3. Bump the `version` field in `package.json` following SemVer.
4. Update [`CHANGELOG.md`](CHANGELOG.md) with a new entry.
5. Publish:
   ```bash
   npm run package         # sanity-check the .vsix first
   npx vsce publish        # uploads to marketplace + creates a tag
   ```

VS Code's
[publishing guide](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
has the full reference.

## Updating semantic-token mappings

The mapping from tree-sitter node types onto VS Code semantic-token
types lives in `src/extension.ts` (the `DocumentSemanticTokensProvider`
implementation). The `contributes.semanticTokenScopes` block in
`package.json` maps each of those semantic-token types back onto a
TextMate scope so themes that don't directly support semantic tokens
still get colours.

When `tree-sitter-m` adds new node types, both halves typically need
to be updated:

1. Add the node-type → semantic-token mapping in
   [`src/extension.ts`](src/extension.ts).
2. Add the semantic-token → TextMate-scope mapping in the
   `semanticTokenScopes` section of
   [`package.json`](package.json).
3. Rebuild the WASM if the grammar itself changed:
   `npm run build-wasm`.
4. Validate against the routines in `test-routines/` and (ideally)
   a real corpus via the smoke-report command.

## Filing parse-tree bugs

If a routine highlights incorrectly or the smoke-report flags it as
malformed, the underlying issue is almost always in the grammar
itself rather than this extension. Open issues against
[`tree-sitter-m`](https://github.com/rafael5/tree-sitter-m/issues)
with:

- A minimal reproducing routine.
- The expected vs. actual parse tree (from `npx tree-sitter parse`).
- A note that you found it via this extension, if relevant.

## License

By contributing, you agree that your contributions will be licensed
under the [AGPL-3.0-only](LICENSE) license used by the rest of the
project.
