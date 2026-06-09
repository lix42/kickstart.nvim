---
name: nvim-help
description: Answer "how do I…" questions about this Neovim config — features, usage, and keyboard shortcuts (e.g. "how to open the file browser", "how to show the diff view", "how to show the current file's location"). Resolves the answer from THIS repo's actual config first, then the curated guide, then stock kickstart/Neovim defaults. Use whenever the user asks how to do something in their editor, which key does X, or what shortcut exists for Y.
---

# Answer a "how do I…" question about this Neovim config

The user is asking how to do something in their editor. Resolve it against **their actual config**, not generic Neovim memory. Their config overrides defaults (leader is `,`, tab width 2, custom keymaps, extra plugins), so a stock answer is often wrong here.

Per the global rule "verify before assuming": never answer a keybind from memory. Grep the config and confirm the mapping exists before stating it.

## Sources, in priority order

1. **The live config (source of truth).** A keymap that's actually bound here wins over anything written in docs.
   - `init.lua` — leader/options, core keymaps, every inline-configured plugin (Telescope, LSP, neo-tree reveal, buffers `,b`, windows `,w`, flash `s`, etc.). ~939 lines, numbered `do…end` sections.
   - `lua/custom/plugins/*.lua` — our standalone features: `colorscheme.lua`, `markdown.lua` (`,m` prefix).
   - `lua/kickstart/plugins/*.lua` — optional modules that are enabled: `neo-tree.lua` (`\`), `gitsigns.lua` (`,h` prefix), `lint.lua`, `debug.lua`, `autopairs.lua`, `indent_line.lua`. Confirm a module is actually `require`-d in init.lua Section 10 before quoting it — a file existing doesn't mean it's loaded.
   - `diffview` (`,g` prefix) is configured in `init.lua`.

2. **The curated guide** `nvim-guide.html` — human-written keybind tables grouped by task (Telescope, explorer/buffers/windows, LSP, git/diffview, markdown, etc.). Fast to scan and already organized by intent, but the live config is authoritative if they ever disagree (flag the drift if so).

3. **Stock kickstart / Neovim defaults** — only for things this config doesn't override. State clearly when an answer is a Neovim default rather than a custom binding, and remember leader is `,` not `\`.

## How to find the answer

Search by the *intent*, since the user rarely knows the plugin name:

```bash
# keybinds + their descriptions (desc = "..." is the searchable label)
grep -rnE "vim\.keymap\.set|desc *=|keys *=" init.lua lua/custom/plugins lua/kickstart/plugins

# narrow by what they're trying to do — match against desc strings and command names
grep -rinE "explorer|neo-tree|reveal|diff|diffview|git|buffer|window|format|rename|definition|grep|find file|markdown|preview" init.lua lua/ nvim-guide.html
```

The curated tables in `nvim-guide.html` are the quickest lookup for common asks — grep it first for a likely answer, then confirm the exact key against `init.lua`/the plugin file.

For a few common examples mapped to where the answer lives:
- "open the file browser / explorer" → `\` (neo-tree reveal), `lua/kickstart/plugins/neo-tree.lua` + init.lua
- "show the diff / git changes" → diffview `,g` prefix and gitsigns `,h` prefix
- "show current file location / path" → check lualine config + neo-tree reveal-current-file in init.lua; the file path also shows in the statusline
- "find files / search text" → Telescope `,s` prefix in init.lua

If a plugin's own keymaps aren't obvious from the config (set internally by the plugin), say so and, if useful, check the plugin's docs via Context7 rather than guessing.

## Answer format

- Lead with the **key sequence** (write leader as `,`, e.g. ``,sf`` not `<leader>sf`) and one line on what it does.
- Cite where it's defined: `init.lua:NNN` or the plugin file — clickable, and lets them rebind it.
- If multiple ways exist (e.g. a keymap and a `:Command`), give the fastest first, then the alternative.
- If it's a Neovim/kickstart default rather than a custom binding, label it as such.
- If nothing is bound for what they want, say so plainly and optionally point to how to add it (the `customize` skill), rather than inventing a mapping.
