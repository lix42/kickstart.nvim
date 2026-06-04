# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on kickstart.nvim. Requires **Neovim 0.12+**. The main entry point is `init.lua` which contains most of the configuration in a single file, organized into numbered `do ... end` sections, with optional plugin modules in `lua/kickstart/plugins/`.

## Architecture

- `init.lua` - Main configuration file, split into numbered sections:
  - Section 1 (Foundation): leader keys (`,` leader, space local leader), core options, basic keymaps and autocommands
  - Sections 3-9: plugins, each installed inline via `vim.pack.add { ... }` and configured immediately after with `require('<plugin>').setup { ... }`
  - Section 10: optional `kickstart.plugins.*` modules
- `lua/kickstart/plugins/` - Optional plugin modules; each calls `vim.pack.add` and configures itself, enabled by `require`-ing it in init.lua Section 10
- `lua/custom/plugins/` - **Our customizations that can stand alone.** `init.lua` here auto-loads every other `*.lua` file in the directory. Upstream never touches this directory, so files here never cause rebase conflicts — prefer adding new plugins/features here. Current files:
  - `colorscheme.lua` - kanagawa (wave) active, sonokai (andromeda) registered as an alternative
  - `markdown.lua` - render-markdown.nvim (in-editor) + markdown-preview.nvim (browser), with its own `PackChanged` build hook and `<leader>m` keymaps. If preview fails with a missing binary, run `:call mkdp#util#install()` once.

## Plugin Manager

Uses Neovim's built-in [`vim.pack`](https://neovim.io/doc/user/pack.html) (no external manager):
- `:lua vim.pack.update(nil, { offline = true })` - Inspect plugin state / pending updates
- `:lua vim.pack.update()` - Update all plugins
- See `:help vim.pack`. Build steps (telescope-fzf-native, LuaSnip, nvim-treesitter) run via a `PackChanged` autocommand in Section 2. markdown-preview's binary download is a separate `PackChanged` hook in `lua/custom/plugins/markdown.lua`.

## Verifying a change

`vim.pack` loads synchronously, so a headless start surfaces config errors immediately. macOS has no `timeout`, so invoke nvim directly:

```bash
nvim --headless -u init.lua -c "lua vim.fn.writefile({'cs='..(vim.g.colors_name or 'nil')}, '/tmp/cs.txt')" -c "qa!" 2>/tmp/err.txt
grep -iE "error|E[0-9]{3,}|traceback" /tmp/err.txt && echo "LOAD ERROR" || echo "loads clean"
```

The engineer-facing keybind/workflow guide is `nvim-guide.html` (open in a browser).

## Key Plugins Configured

- **Telescope** - Fuzzy finder (`<leader>s` prefix for search commands)
- **LSP** via nvim-lspconfig + Mason - Language server management (`:Mason` to manage LSP servers)
- **Treesitter** - Syntax highlighting and code parsing
- **blink.cmp** - Autocompletion
- **conform.nvim** - Formatting (`<leader>f` to format)
- **nvim-lint** - Linting
- **which-key** - Shows pending keybinds
- **flash.nvim** - Motion plugin (`s` to jump)
- **neo-tree** - File explorer sidebar (`\` to reveal/close)
- **diffview.nvim** - Git diff/history UI (`<leader>g` prefix)
- **render-markdown / markdown-preview** - Markdown rendering & preview (`<leader>m` prefix; configured in `lua/custom/plugins/markdown.lua`)

## Key Customizations from Stock Kickstart

- Leader is `,` (comma); local leader is Space
- Colorscheme is kanagawa (wave) — see `lua/custom/plugins/colorscheme.lua`
- Tab width set to 2 spaces
- Auto-save on buffer leave/focus lost
- Auto-reload files changed externally
- Clipboard not synced to system by default (use `Y` in visual mode for system clipboard)
- Lualine statusline instead of mini.statusline
- Comment.nvim with `Cmd+/` keybindings
- Buffer (`<leader>b`) and window (`<leader>w`) management keymaps
- Extra LSP servers: `omnisharp` (C#), `pyright` (Python) on top of the web/Rust set

## External Dependencies

- `git`, `make`, C compiler (gcc)
- `ripgrep`, `fd` for Telescope
- Nerd Font (optional, but expected - `vim.g.have_nerd_font = true`)
- Language-specific: `npm` for TypeScript, `go` for Go, etc.

## Maintaining this fork (upstream sync)

This is a personal fork of `nvim-lua/kickstart.nvim`, kept up to date by **rebase, never merge**, so history stays readable.

- Remotes: `origin` = our fork, `upstream` = `nvim-lua/kickstart.nvim`.
- Our changes are a small **thematic commit stack** on top of `upstream/master` — list them with `git log --oneline upstream/master..HEAD`. Themes: `custom: colorscheme`, `custom: markdown`, `custom: init.lua tweaks`, `docs:`.
- `branch.main.rebase`, `rebase.autostash`, and `pull.ff only` are configured, so `git pull` rebases automatically.

**When adding/changing a customization** (prefer the conflict-free path):
1. Self-contained plugin or feature → a new file in `lua/custom/plugins/` (auto-loaded, never conflicts with upstream).
2. Edit to kickstart's own structures (leader, options, `servers` table, parser list, enabling modules) → `init.lua`, which is the only file that conflicts with upstream.
3. Don't append a commit per tweak — fold it into the matching thematic commit: `git commit --fixup <hash>` then `git rebase -i --autosquash upstream/master`, keeping the stack small.

**Syncing upstream:** `git fetch upstream && git rebase upstream/master`, resolve any `init.lua` conflicts, verify with a headless load, then `git push --force-with-lease`.

Two skills automate these: **`sync-upstream`** (the rebase sync) and **`customize`** (add a change + fold it into the stack), in `.claude/skills/`.

**`gh` gotcha:** for a fork, `gh` defaults to the *upstream* repo (`nvim-lua/kickstart.nvim`). The default repo is set to `lix42/kickstart.nvim` for this directory; if `gh` ever targets upstream, pass `--repo lix42/kickstart.nvim`.
