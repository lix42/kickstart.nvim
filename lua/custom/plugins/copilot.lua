-- copilot.vim - inline ("ghost text") AI suggestions from GitHub Copilot.
--
-- Run `:Copilot setup` once to sign in; `:Copilot status` to check state.
-- The language server is fetched on demand via `npx @github/copilot-language-server`,
-- so `node` and `npx` must be on PATH.
--
-- How this splits keys with blink.cmp: Copilot only hides its ghost text for the
-- built-in pmenu, which blink does not use, so blink's menu and Copilot's ghost
-- text can be on screen at the same time. Each gets its own accept key:
--   <C-y>  accept the blink menu item
--   <Tab>  accept the Copilot suggestion  (blink's <Tab>/<S-Tab> are off in init.lua)
-- Copilot's own defaults stay as-is: <M-]>/<M-[> cycle, <M-\> request,
-- <M-Right> accept a word, <C-]> dismiss.

-- Must be set before the plugin is sourced: we map <Tab> ourselves below rather
-- than letting copilot.vim wrap whatever <Tab> mapping happens to exist at VimEnter.
vim.g.copilot_no_tab_map = true

vim.pack.add { 'https://github.com/github/copilot.vim' }

-- Accepts the whole suggestion; inserts a literal <Tab> when none is showing.
-- `replace_keycodes = false` so the key sequence copilot#Accept() returns is
-- passed through untouched.
vim.keymap.set('i', '<Tab>', 'copilot#Accept("\\<Tab>")', {
  expr = true,
  replace_keycodes = false,
  desc = 'Accept Copilot suggestion',
})
