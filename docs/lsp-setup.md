# Self-trial setup: m-cli LSP in VS Code

This is the local-install path for trying the `m-cli` Language Server in
VS Code as the only initial user. It does **not** require publishing
`m-cli` or `tree-sitter-m` to PyPI / a git host.

## Prerequisites

You already have these on disk:

  - `~/projects/m-cli` — the m-cli source, with `.venv/bin/m` working
  - `~/projects/tree-sitter-m-vscode` — this extension's source

Confirm the binary works:

```bash
~/projects/m-cli/.venv/bin/m --version
~/projects/m-cli/.venv/bin/m lsp --help
```

## Install the extension

Build and install the `.vsix` from this repo (it's already in the repo
root after a `npm run package`):

```bash
cd ~/projects/tree-sitter-m-vscode
npm install                      # only on first run / dep changes
npm run compile                  # TypeScript -> out/
npm run package                  # bundles to tree-sitter-m-vscode-0.1.0.vsix
code --install-extension tree-sitter-m-vscode-0.1.0.vsix
```

Restart VS Code (or reload the window — `Developer: Reload Window`).

## Point the extension at your `m` binary

The default is `m` on PATH; your venv binary isn't on PATH, so set the
absolute path. Open VS Code settings (Ctrl+,) and add to your
`settings.json`:

```jsonc
{
  "m-cli.path": "/home/rafael/projects/m-cli/.venv/bin/m",
  "m-cli.enabled": true,
  // Optional: see LSP traffic in the Output panel ("m-cli LSP")
  "m-cli.trace.server": "messages"
}
```

## Try it

Open any `.m` file, e.g. `~/projects/m-tools/routines/tests/HELLOTST.m`:

```bash
code ~/projects/m-tools/routines/tests/HELLOTST.m
```

Expected behavior:

  - **Squiggles** appear under lint findings within ~1 s of opening
    (M-XINDX-013, M-XINDX-047, etc.).
  - **Format Document** (Shift+Alt+F or right-click → Format Document)
    rewrites the file via `format_source(rules=canonical_rules())` —
    uppercases command keywords, trims trailing whitespace.
  - **Quick Fix** (Ctrl+. on a diagnostic) shows actions like
    "Apply: Strip trailing whitespace from every line".
  - The Output panel has an `m-cli LSP` channel showing server messages
    when `m-cli.trace.server` is `"messages"` or `"verbose"`.

## Troubleshooting

If diagnostics never appear:

  1. Open the Output panel → select `m-cli LSP` from the dropdown.
     If empty, the server didn't start; check the extension's error
     toast.
  2. Run `~/projects/m-cli/.venv/bin/m lsp --help` from a terminal —
     should print usage. If it errors with a missing-dependency
     message, run `cd ~/projects/m-cli && uv sync --extra dev` (the
     dev extra includes the `lsp` extra's deps).
  3. Verify `m-cli.path` is set to an absolute path and that the file
     exists: `ls -l "$(jq -r '.["m-cli.path"]' ~/.config/Code/User/settings.json)"`.
  4. Run `M (MUMPS): Restart Language Server` from the Command Palette
     (Ctrl+Shift+P) after changing settings.

## What's wired up

  - `textDocument/didOpen` / `didChange` / `didSave` → live lint
    diagnostics (Stage 1)
  - `textDocument/formatting` → format-on-save / Format Document
    runs the full canonical-layout pipeline (Stage 2)
  - `textDocument/codeAction` → Quick Fix per `Rule.fixer_id`,
    one click per distinct fixer (Stage 3)

Stage 4 (workspace config beyond `m-cli.*`, hover, completion) is
intentionally not yet implemented — it'll be driven by what's
annoying in real use.
