---
# Machine-readable project descriptor — schema v1 (2026-05-05).
name: tree-sitter-m-vscode
kind: [vscode-extension]
status: active
languages: [typescript, javascript]

runtime:
  needs:
    - "vscode (Desktop or Web)"
    - "tree-sitter-m (compiled to WASM, loaded by the extension)"
  optional: []
  excludes: []

distribution:
  pypi: null
  github: rafael5/tree-sitter-m-vscode
  vscode_marketplace: null                  # not yet published

location: ~/projects/tree-sitter-m-vscode

exposes:
  vsix: "build artefact (run package script)"
  language_ids: [m, mumps]
  file_extensions: [".m", ".mac", ".int"]
  features:
    - "syntax highlighting (TextMate-style via tree-sitter-m WASM)"
    - "language tooling (TBD — early stage)"

consumes:
  formats: [".m", ".mac", ".int"]
  services: []
  upstream_grammar: "tree-sitter-m WASM build"

companions:
  - project: tree-sitter-m
    relation: "consumes the WASM build of tree-sitter-m's grammar; rebuild the grammar to refresh syntax classes"
  - project: m-cli
    relation: "future: vscode extension can host m-cli's `m lsp` for live diagnostics + completion"
  - project: m-standard
    relation: "indirect — tree-sitter-m's tokens come from m-standard, so coverage flows through"
  - project: vista-meta
    relation: "vista-meta ships its own VSCode extension (situational-awareness sidebar); both can co-exist on the same .m file"

incompatibilities:
  - "Works on VSCode Desktop and Web — not on JetBrains / other IDEs."
  - "WASM bundle is committed; rebuilding requires the tree-sitter-m repo + emscripten."

docs:
  primary: README.md
---

# tree-sitter-m-vscode

Minimal VS Code language-support extension for M (MUMPS), powered by
the `tree-sitter-m` grammar compiled to WASM. Recognises `.m`, `.mac`,
and `.int` files; works on VS Code Desktop and Web.

See [README.md](README.md) for features, install, and configuration.

## How it relates to vista-meta's extension

Both extensions can be installed simultaneously:

- `tree-sitter-m-vscode` — language-level features (highlighting, parsing).
- `vista-meta/vscode-extension/` — VistA-specific situational-awareness sidebar (per-routine TSV reads).

They don't overlap; the first is about syntax, the second is about VistA semantics.

## Setup

```bash
git clone https://github.com/m-dev-tools/tree-sitter-m-vscode
cd tree-sitter-m-vscode
npm ci                        # installs typescript, vsce, vscode types, web-tree-sitter
```

Node ≥ 20 and VS Code ≥ 1.85 (per `package.json` `engines.vscode`). The
`dist/tree-sitter-m.wasm` payload is committed, so installs don't need
docker or the sibling `tree-sitter-m` checkout. Only `scripts/build-wasm.sh`
needs docker — and that's only run when refreshing the grammar.

## Test

This repo doesn't carry an automated test harness — the runtime artefacts
(`.wasm` grammar, `m.tmLanguage.json`, the TypeScript extension host)
are validated in-editor on a real VS Code workbench. The closest thing
to a smoke check is the **compile gate** (TypeScript type-checking):

```bash
npm run lint                  # tsc -noEmit -p ./  (strict mode)
npm run compile               # tsc -p ./           (writes out/extension.js)
```

`test-routines/` holds sample `.m` files used to eyeball syntax
highlighting and LSP wiring inside an Extension Development Host.

## Build / generate

The hand-authored manifest payloads under `dist/` are:

- `dist/repo.meta.json` — Phase-0 contract.
- `dist/extension-info.json` — distilled view of `package.json`
  `contributes.*` (languages, grammars, commands, settings) for the
  AI-discoverability catalog. Sorted keys, 2-space indent.
- `dist/tree-sitter-m.wasm` — committed grammar artefact, rebuilt via
  `scripts/build-wasm.sh` (docker + emscripten) when the upstream
  `tree-sitter-m` grammar changes.

```bash
npm run compile               # → out/extension.js
npm run package               # → tree-sitter-m-vscode-<version>.vsix (via vsce)
scripts/build-wasm.sh         # → dist/tree-sitter-m.wasm  (docker + tree-sitter CLI)
```

`make manifest` is a no-op pointer — `dist/extension-info.json` and
`dist/repo.meta.json` are hand-authored. When `package.json`'s
`contributes.*` blocks change in a way that affects an external claim
(commands, settings, file associations, engine version), update
`dist/extension-info.json` in the same commit (captured in Guardrails).

## Verify

The `verification_commands` declared in `dist/repo.meta.json`:

```bash
make check-manifest           # dist/repo.meta.json valid + every exposes.* path exists
```

Cross-repo guardrail:

```bash
make check-docs-prose         # docs/ holds only prose
```

## Guardrails

- **Don't hand-edit `dist/tree-sitter-m.wasm`.** It is a
  `scripts/build-wasm.sh` output, sourced from the sibling
  `tree-sitter-m` grammar. Regenerate when that grammar changes.
- **`dist/extension-info.json` is derived from `package.json`.** Don't
  let the two drift — when a setting, command, language, or grammar
  is added/removed in `package.json` `contributes.*`, mirror the
  change into `dist/extension-info.json` in the same commit. The
  Phase-0 manifest gate doesn't yet diff the two, so this is a
  reviewer-enforced rule.
- **Don't hand-edit `dist/repo.meta.json` `verified_on` to a future
  date.** The org smoke test rejects manifests older than 90 days;
  bump the date only when the manifest changes materially.
- **`dist/` is committed.** Despite the typical `dist/` ignore in
  Node projects, this repo deliberately tracks `dist/` so end users
  can clone-and-package the extension without docker. Don't add
  `dist/` to `.gitignore`.
- **Marketplace identity is contract.** `publisher` (`rafael5`) and
  `name` (`tree-sitter-m-vscode`) form the marketplace ID
  (`rafael5.tree-sitter-m-vscode`). Renaming either is a breaking
  change for installed users.
- **LSP integration spawns `m lsp` from m-cli.** The extension does
  not bundle a language server — it shells out to the user's
  `m-cli.path`. Keep the LSP code defensive (cope with `m` not
  installed); never assume m-cli is on `PATH`.
- **ObjectScript is out of scope.** This extension targets M and M
  dialects (AnnoStd, YottaDB, IRIS M). InterSystems ObjectScript
  features (`##class`, `&sql`, `obj.method()`) belong in a sibling
  extension.
