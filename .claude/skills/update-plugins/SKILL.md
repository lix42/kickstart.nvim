---
name: update-plugins
description: Update this Neovim config's plugins via vim.pack, verify the config still loads, and commit the refreshed lockfile into the right thematic commit. Use when the user wants to "update plugins", "bump plugins", "run vim.pack update", or refresh nvim-pack-lock.json. Distinct from sync-upstream (which tracks kickstart itself).
---

# Update plugins (vim.pack)

This refreshes installed plugin versions and the tracked `nvim-pack-lock.json`. It is **not** the same as `sync-upstream` (which rebases onto kickstart upstream) — use this when you just want newer plugin revisions.

## Procedure

1. **Inspect what would change** (offline, no network writes):
   ```bash
   nvim --headless -c "lua vim.pack.update(nil, { offline = true })" -c "qa!"
   ```

2. **Update** all plugins. This is interactive in a real session (opens a confirmation buffer); headless it applies directly:
   ```bash
   nvim --headless -c "lua vim.pack.update()" -c "qa!" 2>/tmp/pack_err.txt
   grep -iE "error|E[0-9]{3,}|traceback" /tmp/pack_err.txt && echo "UPDATE ERROR — investigate" || echo "update ran"
   ```
   Build steps (telescope-fzf-native, LuaSnip, nvim-treesitter, markdown-preview) run automatically via their `PackChanged` hooks.

3. **Verify the config still loads** with the new versions (macOS has no `timeout` — call nvim directly):
   ```bash
   nvim --headless -u init.lua -c "lua vim.fn.writefile({'cs='..(vim.g.colors_name or 'nil')}, '/tmp/cs.txt')" -c "qa!" 2>/tmp/err.txt
   grep -iE "error|E[0-9]{3,}|traceback" /tmp/err.txt && echo "LOAD ERROR" || echo "loads clean"
   cat /tmp/cs.txt   # expect cs=kanagawa
   ```
   If a plugin's update broke something, check its README/changelog (use the context7 MCP for current docs) before pinning or adjusting config.

4. **Review the lockfile diff** — it should be only `rev` bumps:
   ```bash
   git diff nvim-pack-lock.json
   ```

5. **Commit** by folding into the matching thematic commit, not appending (see the `customize` skill). A plugin bump usually belongs with whichever commit owns that plugin — or, if it's a broad refresh, the `custom: init.lua tweaks` commit:
   ```bash
   git add nvim-pack-lock.json
   git commit --fixup <hash>
   GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash upstream/master
   git push --force-with-lease
   ```

## Notes
- If an update pulls a plugin version that needs a config change, make that change in the same fold so the lockfile and config stay consistent.
- To roll back a bad update, `git checkout nvim-pack-lock.json` (before committing) and re-run step 2, or pin the plugin with a `version` in its `vim.pack.add` spec.
