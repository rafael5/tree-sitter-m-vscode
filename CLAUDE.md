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
