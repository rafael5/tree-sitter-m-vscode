# tree-sitter-m-vscode — VS Code extension Makefile.
#
# Most extension lifecycle (compile, package, lint) goes through
# `npm run …` per VS Code convention. This Makefile only adds the
# Phase-0 AI-discoverability targets so verification_commands in
# dist/repo.meta.json line up with the other org repos.

.PHONY: manifest check-manifest check-docs-prose

# ── Phase-0 AI-discoverability contract ───────────────────────────────
#
# Tier-3 entry to the org catalog. See
# https://github.com/m-dev-tools/.github/blob/main/docs/AI-discoverability-plan.md
#
# `dist/repo.meta.json` and `dist/extension-info.json` are hand-authored,
# not regenerated — the source of truth for the extension's commands,
# settings, languages, and grammars is `package.json` `contributes.*`,
# already committed. When `package.json` changes in a way that affects
# an external claim (commands added/removed, settings renamed, file
# associations expanded), update `dist/extension-info.json` in the same
# commit (captured in AGENTS.md § Guardrails).
#
# `make manifest` is therefore a no-op pointer — it exists so
# verification_commands in dist/repo.meta.json line up with other org
# repos.

manifest:
	@echo "tree-sitter-m-vscode: dist/extension-info.json is hand-authored alongside package.json."
	@echo "  see AGENTS.md § Build / generate for the rebuild-when-it-changes guardrail."

check-manifest:
	python3 tools/check-manifest.py

# Guardrail: docs/ holds only human-readable prose. Same target name
# as the tier-1 repos so cross-repo muscle memory works.
check-docs-prose:
	@if [ ! -d docs ]; then echo "check-docs-prose: no docs/ directory ✓"; exit 0; fi; \
	violations=$$(find docs -type f \
	    ! -name '*.md' ! -name '*.markdown' \
	    ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' \
	    ! -name '*.gif' ! -name '*.svg' ! -name '*.webp' \
	    ! -name '.gitkeep'); \
	if [ -n "$$violations" ]; then \
	  echo "ERROR: non-prose files under docs/ — move to a top-level domain dir:" >&2; \
	  echo "$$violations" >&2; \
	  exit 1; \
	fi; \
	echo "check-docs-prose: docs/ is prose-only ✓"
