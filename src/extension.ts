// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (c) 2026 Rafael Richards. See LICENSE in the repo root.
//
// VS Code extension entry point for the M (MUMPS) language.
//
// Phase 1 (this version): registers the language and its TextMate
// grammar via package.json's `contributes` section. The activation
// hook below is a no-op aside from a console announcement — VS Code
// applies the TextMate grammar based on the manifest alone.
//
// Phase 2 (post tree-sitter-m npm publish): wire a semantic tokens
// provider that parses each document with tree-sitter-m (compiled to
// WASM via `tree-sitter build --wasm`) and emits VS Code semantic
// tokens. The TextMate grammar then becomes the cold-load fallback;
// semantic tokens overlay the precise tree-sitter-driven highlighting
// once parsing finishes (fast — see tree-sitter-m perf bench: 78.6 ms
// for a 10k-line synthesised routine).
//
// Why WASM and not the Node binding: VS Code extensions don't have a
// reliable way to require native .node addons across user platforms
// without shipping prebuilds. tree-sitter's web-tree-sitter runtime
// loads a single .wasm file that works everywhere VS Code runs.

import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): void {
  // The TextMate grammar in syntaxes/m.tmLanguage.json is wired through
  // package.json's `contributes.grammars` — VS Code activates it
  // automatically for documents matching the .m / .mac / .int file
  // extensions. No code-side wiring is needed for that path.

  // Hello-world breadcrumb so users can confirm the extension loaded
  // (visible in Help > Toggle Developer Tools > Console).
  console.log('tree-sitter-m-vscode: activated. Phase 1 — TextMate grammar only.');

  // Phase 2 sketch — uncomment and wire once tree-sitter-m is published
  // to npm and the WASM build is bundled in dist/tree-sitter-m.wasm:
  //
  //   const Parser = require('web-tree-sitter');
  //   await Parser.init();
  //   const M = await Parser.Language.load(
  //     context.asAbsolutePath('dist/tree-sitter-m.wasm')
  //   );
  //   const parser = new Parser();
  //   parser.setLanguage(M);
  //
  //   const provider: vscode.DocumentSemanticTokensProvider = {
  //     provideDocumentSemanticTokens(doc) {
  //       const tree = parser.parse(doc.getText());
  //       const builder = new vscode.SemanticTokensBuilder(LEGEND);
  //       walk(tree.rootNode, builder, doc);
  //       return builder.build();
  //     },
  //   };
  //   context.subscriptions.push(
  //     vscode.languages.registerDocumentSemanticTokensProvider(
  //       { language: 'm' }, provider, LEGEND
  //     )
  //   );

  context.subscriptions.push(
    vscode.commands.registerCommand('tree-sitter-m.about', () => {
      vscode.window.showInformationMessage(
        'tree-sitter-m-vscode v0.1.0 — TextMate grammar active. ' +
          'Tree-sitter-driven semantic highlighting lands in v0.2 once ' +
          'the tree-sitter-m npm package publishes.'
      );
    })
  );
}

export function deactivate(): void {
  // Nothing to clean up in Phase 1.
}
