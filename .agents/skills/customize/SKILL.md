---
name: customize
description: Add or change a customization in this Neovim config fork the conflict-resistant way, then fold it into the thematic commit stack instead of appending a new commit. Use when adding a plugin, changing a keymap/option/colorscheme/LSP server, or when the user asks how to "add a customization", "keep the history clean", or "commit a config change".
---

# Add/modify a customization without bloating the fork's history

This repo keeps its customizations as a **fixed, small thematic stack** on top of `upstream/master`. The goal: the stack size stays constant over time, and each upstream sync replays the same handful of commits. Two rules make that work.

## Rule 1 — Put the change in the least-conflict-prone place

In order of preference:

1. **New self-contained plugin or feature → a new file in `lua/custom/plugins/`.**
   `lua/custom/plugins/init.lua` auto-loads every `*.lua` sibling, and upstream never touches this directory, so these files **never** cause rebase conflicts. Examples already here: `colorscheme.lua`, `markdown.lua`. Use full GitHub URLs in `vim.pack.add` (the `gh` helper is local to `init.lua`). If a plugin needs a build step, register its own `PackChanged` autocommand in the same file (see `markdown.lua`).

2. **Edit to kickstart's own structures** (leader keys, core `vim.o` options, the LSP `servers` table, the treesitter parser list, enabling `kickstart.plugins.*` modules) → edit `init.lua` directly. These can't cleanly move out; they belong to the `custom: init.lua tweaks` commit. This is the only file that conflicts with upstream, and that's expected.

## Rule 2 — Fold into the matching thematic commit, don't append

Find the current stack (hashes change after every rebase, so always look them up):

```bash
git log --oneline upstream/master..HEAD
```

Typical themes:
- `custom: colorscheme …`        → `lua/custom/plugins/colorscheme.lua`
- `custom: markdown …`           → `lua/custom/plugins/markdown.lua`
- `custom: init.lua tweaks …`    → `init.lua`, `lint.lua`, `.gitignore`, lockfile
- `docs: …`                      → `AGENTS.md`, `nvim-guide.html`
- (a genuinely new, separate concern → a new thematic commit is fine)

Then fold your change in:

```bash
# make the edit, then:
git add <files>
git commit --fixup <hash-of-matching-theme>
# squash the fixup into its target. The env var makes the -i rebase non-interactive
# (required when an agent runs it; a human can omit it and just save the editor):
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash upstream/master
git push --force-with-lease
```

## Verify before pushing

`vim.pack` is synchronous, so a headless load surfaces errors immediately (no `timeout` on macOS — call nvim directly):

```bash
nvim --headless -u init.lua -c "lua vim.fn.writefile({'cs='..(vim.g.colors_name or 'nil')}, '/tmp/cs.txt')" -c "qa!" 2>/tmp/err.txt
grep -iE "error|E[0-9]{3,}|traceback" /tmp/err.txt && echo "LOAD ERROR" || echo "loads clean"
```

If you also changed plugins, `nvim-pack-lock.json` will update — stage it with the same commit. To sync upstream afterwards, use the `sync-upstream` skill.
