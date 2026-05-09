# Changelog

All notable changes to the **M (MUMPS)** VS Code extension are
documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-04-27

### Added

- Initial public release.
- Language registration for `.m`, `.mac`, and `.int` files.
- TextMate grammar (`syntaxes/m.tmLanguage.json`) for cold-load
  highlighting.
- `DocumentSemanticTokensProvider` powered by
  [`tree-sitter-m`](https://github.com/m-dev-tools/tree-sitter-m)
  compiled to WASM via `web-tree-sitter`.
- Semantic-token scope mappings (`semanticTokenScopes`) so common
  themes colour M tokens correctly without configuration.
- Editor defaults for `[m]` (one-space tab, semantic highlighting
  on, indentation auto-detection off).
- Comment, bracket, and auto-closing-pair rules via
  `language-configuration.json`.
- Three Command Palette commands:
  - `M (MUMPS): About this extension`
  - `M (MUMPS): Open all M files in workspace as tabs`
  - `M (MUMPS): Smoke-report all M files in workspace`
- `scripts/open-all.sh` CLI for opening a directory of M routines
  as tabs in a fresh VS Code window.
- Curated `test-routines/` corpus exercising the highlighting
  surface (commands, intrinsic functions, special variables,
  operators, pattern codes, postconditionals, dot-blocks, formal
  parameters, vendor extensions, and a real VistA Kernel routine).

### Known limitations

- No language-server features yet (no completion, hover, go-to,
  diagnostics, formatter, or linting). These are planned for
  future releases.
- No theme-specific default colour bundle — relies on themes' own
  TextMate styling via `semanticTokenScopes`.

[Unreleased]: https://github.com/m-dev-tools/tree-sitter-m-vscode/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/m-dev-tools/tree-sitter-m-vscode/releases/tag/v0.1.0
