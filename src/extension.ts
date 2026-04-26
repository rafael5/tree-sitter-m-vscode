// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (c) 2026 Rafael Richards. See LICENSE in the repo root.
//
// VS Code extension entry point for the M (MUMPS) language.
//
// Two-layer highlighting:
//   1. TextMate grammar (syntaxes/m.tmLanguage.json) handles the
//      cold-load / fallback render via `contributes.grammars` in
//      package.json. It applies regex-based scopes; correct enough
//      to be readable while the parser warms up.
//   2. DocumentSemanticTokensProvider parses the document with
//      tree-sitter-m (compiled to WASM) and emits precise per-node
//      tokens that overlay the TextMate base. The provider walks the
//      parse tree and maps node types to the VS Code semantic-token
//      legend below.
//
// The WASM lives at dist/tree-sitter-m.wasm. Rebuild from the parser
// source via `scripts/build-wasm.sh`.

import * as vscode from 'vscode';
import * as path from 'path';
import { Parser, Language, Node, Tree } from 'web-tree-sitter';

// ---- Semantic token legend ------------------------------------------------
// Token types and modifiers VS Code knows about. Themes color these via
// editor.semanticTokenColorCustomizations; consumers pick whichever subset
// their theme styles. Keep this conservative — adding a custom type means
// it falls back to "no color" for users whose theme doesn't know it.

const TOKEN_TYPES = [
  'keyword',
  'function',
  'variable',
  'parameter',
  'string',
  'number',
  'comment',
  'operator',
  'namespace',
] as const;
type TokenType = typeof TOKEN_TYPES[number];

const TOKEN_MODIFIERS = [
  'declaration',
  'readonly',
  'defaultLibrary',
] as const;
type TokenModifier = typeof TOKEN_MODIFIERS[number];

const LEGEND = new vscode.SemanticTokensLegend(
  TOKEN_TYPES as unknown as string[],
  TOKEN_MODIFIERS as unknown as string[],
);

// ---- Node-type → (token type, modifiers) map ------------------------------
//
// Whole-node mappings: when the parser produces a node of this type, emit a
// single token spanning startIndex..endIndex with the given type+modifiers.

const WHOLE_NODE: Record<string, [TokenType, TokenModifier[]] | undefined> = {
  comment:                       ['comment', []],
  string:                        ['string', []],
  number:                        ['number', []],
  command_keyword:               ['keyword', []],
  intrinsic_function_keyword:    ['function', ['defaultLibrary']],
  special_variable_keyword:      ['variable', ['defaultLibrary', 'readonly']],
  vendor_sv_extension:           ['variable', ['defaultLibrary', 'readonly']],
  pattern_letter:                ['keyword', ['defaultLibrary']],
  operator:                      ['operator', []],
  format_control:                ['operator', []],
  format_tab:                    ['operator', []],
  dot_block_prefix:              ['operator', []],
  global_variable:               ['variable', []],
  numeric_label_call:            ['function', []],
};

// Child-anchored mappings: emit a token only for a specific child of the
// listed parent type. This handles cases like `(local_variable (identifier))`
// where the identifier carries the highlight, not the wrapper.

interface ChildRule {
  parent: string;
  childType: string;
  tokenType: TokenType;
  modifiers: TokenModifier[];
}

const CHILD_RULES: ChildRule[] = [
  { parent: 'line',                childType: 'label',      tokenType: 'function',  modifiers: ['declaration'] },
  { parent: 'local_variable',      childType: 'identifier', tokenType: 'variable',  modifiers: [] },
  { parent: 'extrinsic_function',  childType: 'identifier', tokenType: 'function',  modifiers: [] },
  { parent: 'extrinsic_function',  childType: 'number',     tokenType: 'function',  modifiers: [] },
  { parent: 'entry_reference',     childType: 'identifier', tokenType: 'function',  modifiers: [] },
  { parent: 'entry_reference',     childType: 'number',     tokenType: 'function',  modifiers: [] },
  { parent: 'by_reference',        childType: 'identifier', tokenType: 'parameter', modifiers: [] },
  { parent: 'formals',             childType: 'identifier', tokenType: 'parameter', modifiers: ['declaration'] },
  { parent: 'postconditional',     childType: ':',          tokenType: 'keyword',   modifiers: [] },
  { parent: 'argument_postconditional', childType: ':',     tokenType: 'keyword',   modifiers: [] },
];

// ---- Parser singleton (lazy init) -----------------------------------------

let parserPromise: Promise<Parser> | null = null;

async function getParser(extensionPath: string): Promise<Parser> {
  if (!parserPromise) {
    parserPromise = (async () => {
      await Parser.init();
      const wasmPath = path.join(extensionPath, 'dist', 'tree-sitter-m.wasm');
      const language = await Language.load(wasmPath);
      const parser = new Parser();
      parser.setLanguage(language);
      return parser;
    })();
  }
  return parserPromise;
}

// ---- Tree walker ----------------------------------------------------------

function modifierMask(modifiers: TokenModifier[]): number {
  let mask = 0;
  for (const m of modifiers) {
    const idx = TOKEN_MODIFIERS.indexOf(m);
    if (idx >= 0) mask |= 1 << idx;
  }
  return mask;
}

function tokenTypeIndex(type: TokenType): number {
  return TOKEN_TYPES.indexOf(type);
}

function emit(
  builder: vscode.SemanticTokensBuilder,
  doc: vscode.TextDocument,
  startIndex: number,
  endIndex: number,
  tokenType: TokenType,
  modifiers: TokenModifier[],
): void {
  const start = doc.positionAt(startIndex);
  const end = doc.positionAt(endIndex);
  // Semantic tokens cannot span line boundaries; clamp to single line.
  if (start.line !== end.line) return;
  const length = end.character - start.character;
  if (length <= 0) return;
  builder.push(start.line, start.character, length, tokenTypeIndex(tokenType), modifierMask(modifiers));
}

function walk(
  node: Node,
  builder: vscode.SemanticTokensBuilder,
  doc: vscode.TextDocument,
): void {
  // Whole-node rule first.
  const whole = WHOLE_NODE[node.type];
  if (whole) {
    emit(builder, doc, node.startIndex, node.endIndex, whole[0], whole[1]);
  }

  // Child-anchored rules — fire when this node matches a parent in CHILD_RULES.
  const childRules = CHILD_RULES.filter((r) => r.parent === node.type);
  if (childRules.length > 0) {
    for (let i = 0; i < node.namedChildCount; i++) {
      const child = node.namedChild(i);
      if (!child) continue;
      const rule = childRules.find((r) => r.childType === child.type);
      if (rule) {
        emit(builder, doc, child.startIndex, child.endIndex, rule.tokenType, rule.modifiers);
      }
    }
    // Also walk anonymous children for token-literal child rules (e.g. ":").
    for (let i = 0; i < node.childCount; i++) {
      const child = node.child(i);
      if (!child || child.isNamed) continue;
      const rule = childRules.find((r) => r.childType === child.type);
      if (rule) {
        emit(builder, doc, child.startIndex, child.endIndex, rule.tokenType, rule.modifiers);
      }
    }
  }

  // Recurse into named children.
  for (let i = 0; i < node.namedChildCount; i++) {
    const child = node.namedChild(i);
    if (child) walk(child, builder, doc);
  }
}

// ---- Provider -------------------------------------------------------------

class MSemanticTokensProvider implements vscode.DocumentSemanticTokensProvider {
  constructor(private readonly extensionPath: string) {}

  async provideDocumentSemanticTokens(
    doc: vscode.TextDocument,
    _token: vscode.CancellationToken,
  ): Promise<vscode.SemanticTokens> {
    const parser = await getParser(this.extensionPath);
    const tree: Tree | null = parser.parse(doc.getText());
    const builder = new vscode.SemanticTokensBuilder(LEGEND);
    if (tree) walk(tree.rootNode, builder, doc);
    return builder.build();
  }
}

// ---- Activation -----------------------------------------------------------

export function activate(context: vscode.ExtensionContext): void {
  console.log('tree-sitter-m-vscode: activated.');

  const provider = new MSemanticTokensProvider(context.extensionPath);
  context.subscriptions.push(
    vscode.languages.registerDocumentSemanticTokensProvider(
      { language: 'm' },
      provider,
      LEGEND,
    ),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('tree-sitter-m.about', () => {
      vscode.window.showInformationMessage(
        'tree-sitter-m-vscode v0.1.0 — TextMate grammar + tree-sitter-m semantic tokens.',
      );
    }),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('tree-sitter-m.openAllInWorkspace', async () => {
      const folders = vscode.workspace.workspaceFolders;
      if (!folders || folders.length === 0) {
        vscode.window.showWarningMessage('Open a folder first (File → Open Folder…).');
        return;
      }
      const cap = 200;
      const files = await vscode.workspace.findFiles('**/*.{m,mac,int}', null, cap);
      if (files.length === 0) {
        vscode.window.showInformationMessage('No M files (.m / .mac / .int) found in this workspace.');
        return;
      }
      for (const uri of files) {
        const doc = await vscode.workspace.openTextDocument(uri);
        await vscode.window.showTextDocument(doc, { preview: false, preserveFocus: true });
      }
      const more = files.length === cap ? ` (capped at ${cap})` : '';
      vscode.window.showInformationMessage(
        `tree-sitter-m: opened ${files.length} M file(s) as tabs${more}.`,
      );
    }),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('tree-sitter-m.smokeReport', async () => {
      const folders = vscode.workspace.workspaceFolders;
      if (!folders || folders.length === 0) {
        vscode.window.showWarningMessage('Open a folder first (File → Open Folder…).');
        return;
      }

      const channel = vscode.window.createOutputChannel('M Smoke Report');
      channel.show(true);
      channel.appendLine(`tree-sitter-m smoke report — workspace: ${folders.map((f) => f.uri.fsPath).join(', ')}`);
      channel.appendLine('');

      const cap = 5000;
      const files = await vscode.workspace.findFiles('**/*.{m,mac,int}', null, cap);
      if (files.length === 0) {
        channel.appendLine('No M files (.m / .mac / .int) found.');
        return;
      }
      channel.appendLine(`Found ${files.length} M file(s)${files.length === cap ? ` (capped at ${cap})` : ''}. Parsing...`);
      channel.appendLine('');

      const parser = await getParser(context.extensionPath);
      const errored: { path: string; firstErrorLine: number }[] = [];
      const t0 = Date.now();
      let totalBytes = 0;
      let cleanCount = 0;
      for (const uri of files) {
        let src: string;
        try {
          const buf = await vscode.workspace.fs.readFile(uri);
          src = Buffer.from(buf).toString('utf8');
        } catch (e) {
          channel.appendLine(`READ FAIL  ${uri.fsPath}: ${e instanceof Error ? e.message : String(e)}`);
          continue;
        }
        totalBytes += src.length;
        const tree = parser.parse(src);
        if (tree && tree.rootNode.hasError) {
          // Find the first ERROR / MISSING node line.
          let firstErrorLine = -1;
          const stack: Node[] = [tree.rootNode];
          while (stack.length > 0 && firstErrorLine < 0) {
            const n = stack.pop()!;
            if (n.type === 'ERROR' || n.isMissing) {
              firstErrorLine = n.startPosition.row + 1;
              break;
            }
            for (let i = n.namedChildCount - 1; i >= 0; i--) {
              const c = n.namedChild(i);
              if (c) stack.push(c);
            }
          }
          errored.push({ path: vscode.workspace.asRelativePath(uri), firstErrorLine });
        } else {
          cleanCount++;
        }
      }
      const elapsed = Date.now() - t0;

      channel.appendLine(`Clean:  ${cleanCount} / ${files.length}  (${(100 * cleanCount / files.length).toFixed(2)}%)`);
      channel.appendLine(`Errors: ${errored.length}`);
      channel.appendLine(`Elapsed: ${elapsed} ms  (${(totalBytes / 1024 / Math.max(elapsed, 1) * 1000).toFixed(1)} KiB/s)`);
      if (errored.length > 0) {
        channel.appendLine('');
        channel.appendLine('Files with parse errors (first ERROR / MISSING line):');
        for (const e of errored.slice(0, 200)) {
          channel.appendLine(`  L${String(e.firstErrorLine).padStart(5)}  ${e.path}`);
        }
        if (errored.length > 200) {
          channel.appendLine(`  ... and ${errored.length - 200} more.`);
        }
      }
    }),
  );
}

export function deactivate(): void {
  // The Emscripten module that backs web-tree-sitter doesn't expose a
  // shutdown hook; resources are reclaimed when the extension host exits.
}
