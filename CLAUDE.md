# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on kickstart.nvim. The main entry point is `init.lua` which contains most of the configuration in a single file, with optional plugin modules in `lua/kickstart/plugins/`.

## Architecture

- `init.lua` - Main configuration file containing:
  - Leader key settings (`,` as leader, space as local leader)
  - Core Neovim options (line numbers, tabs/spaces, search, splits)
  - Basic keymaps and autocommands
  - Plugin specifications for lazy.nvim
- `lua/kickstart/plugins/` - Optional plugin configurations that can be enabled by requiring them in init.lua
- `lua/custom/plugins/` - User's custom plugin additions (currently empty)

## Plugin Manager

Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management:
- `:Lazy` - Open the lazy.nvim UI to view plugin status
- `:Lazy update` - Update all plugins

## Key Plugins Configured

- **Telescope** - Fuzzy finder (`<leader>s` prefix for search commands)
- **LSP** via nvim-lspconfig + Mason - Language server management (`:Mason` to manage LSP servers)
- **Treesitter** - Syntax highlighting and code parsing
- **blink.cmp** - Autocompletion
- **conform.nvim** - Formatting (`<leader>f` to format)
- **nvim-lint** - Linting
- **which-key** - Shows pending keybinds
- **flash.nvim** - Motion plugin (`s` to jump)

## Key Customizations from Stock Kickstart

- Tab width set to 2 spaces
- Auto-save on buffer leave/focus lost
- Auto-reload files changed externally
- Clipboard not synced to system by default (use `Y` in visual mode for system clipboard)
- Lualine statusline instead of mini.statusline
- Comment.nvim with `Cmd+/` keybindings

## External Dependencies

- `git`, `make`, C compiler (gcc)
- `ripgrep`, `fd` for Telescope
- Nerd Font (optional, but expected - `vim.g.have_nerd_font = true`)
- Language-specific: `npm` for TypeScript, `go` for Go, etc.
