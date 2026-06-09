---
name: sync-upstream
description: Sync this Neovim config fork with upstream kickstart.nvim using a rebase (not merge) so history stays a clean thematic stack. Use when the user wants to "sync upstream", "update from kickstart", "pull upstream changes", "rebase onto upstream", or pick up new upstream commits.
---

# Sync this fork with upstream kickstart.nvim

This repo is a personal fork of `nvim-lua/kickstart.nvim`. Our customizations are kept as a **small thematic commit stack on top of `upstream/master`** and synced by **rebase**, never merge, so `git log upstream/master..HEAD` always reads as exactly "what we changed."

- `origin` = our fork, `upstream` = `nvim-lua/kickstart.nvim`.
- `branch.main.rebase`, `rebase.autostash`, and `pull.ff only` are already configured, so `git pull` rebases automatically.

## Procedure

1. **Safety net** — tag the current state so a bad rebase is trivially recoverable:
   ```bash
   git branch -f backup/pre-sync HEAD
   ```

2. **Fetch and preview** what's incoming:
   ```bash
   git fetch upstream
   git log --oneline HEAD..upstream/master      # upstream commits we don't have
   git log --oneline upstream/master..HEAD       # our commits that will replay on top
   ```
   If the first list is empty, we're already up to date — stop.

3. **Rebase** our stack onto the new upstream tip:
   ```bash
   git rebase upstream/master
   ```

4. **Resolve conflicts if any.** Conflicts almost always land in `init.lua` (the one file we edit that upstream also edits). Files in `lua/custom/plugins/` should never conflict. For each conflict: edit the file, `git add <file>`, then `git rebase --continue`. To bail out entirely: `git rebase --abort` (returns to `backup/pre-sync`).

5. **Verify the config still loads** (no `timeout` on macOS — invoke nvim directly):
   ```bash
   nvim --headless -u init.lua -c "lua vim.fn.writefile({'cs='..(vim.g.colors_name or 'nil')}, '/tmp/cs.txt')" -c "qa!" 2>/tmp/err.txt
   grep -iE "error|E[0-9]{3,}|traceback" /tmp/err.txt && echo "LOAD ERROR — investigate" || echo "loads clean"
   cat /tmp/cs.txt   # expect cs=kanagawa
   ```
   Optionally check plugin commands in a markdown buffer (`:RenderMarkdown`, `:MarkdownPreview`).

6. **Push** the rewritten stack:
   ```bash
   git push --force-with-lease
   ```
   Always `--force-with-lease`, never plain `-f`.

7. Once confident, drop the safety branch: `git branch -D backup/pre-sync`.

## Notes
- If upstream made a **breaking change** (e.g. a plugin API or `vim.pack` behavior), the conflict surfaces in whichever thematic commit touches that area — fix it there during the rebase, not as a new commit on top.
- Keep the stack small: new customizations should be folded into the existing thematic commits (see the `customize` skill), not appended, so each sync replays the same handful of commits.
