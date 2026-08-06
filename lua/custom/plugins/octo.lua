-- Octo.nvim: edit and review GitHub issues, PRs and discussions inside Neovim.
-- Lives in lua/custom/plugins/ so it survives upstream syncs without conflicts.
--
-- Requires the GitHub CLI (`gh`) to be installed and authenticated (`gh auth login`).
-- plenary.nvim, telescope.nvim and nvim-web-devicons are already installed by
-- init.lua (Section 5), and this file is loaded from Section 10, so they're ready.

vim.pack.add { 'https://github.com/pwntester/octo.nvim' }

require('octo').setup {
  picker = 'telescope', -- reuse the picker we already configure in init.lua
  enable_builtin = true, -- bare `:Octo` opens a picker listing every subcommand
  default_merge_method = 'squash', -- used by `Octo pr merge` and the picker's merge action
  default_delete_branch = true, -- delete the head branch on merge (override per-merge with `Octo pr merge nodelete`)

  -- Upstream defaults to { 'upstream', 'origin' }, which makes Octo target the
  -- *parent* repo in a fork (the same `gh` gotcha noted in CLAUDE.md). We work on
  -- our own fork, so try `origin` first.
  default_remote = { 'origin', 'upstream' },

  -- GitHub Projects v2 needs an extra token scope. Run
  --   gh auth refresh -s read:project
  -- to enable it; until then, don't nag on every Octo buffer.
  suppress_missing_scope = { projects_v2 = true },
}

-- [[ Octo keymaps ]]
require('which-key').add { { '<leader>o', group = '[O]cto (GitHub)' } }
vim.keymap.set('n', '<leader>oo', '<cmd>Octo<CR>', { desc = '[O]cto command palette' })
vim.keymap.set('n', '<leader>op', '<cmd>Octo pr list<CR>', { desc = '[O]cto [P]ull request list' })
vim.keymap.set('n', '<leader>oP', '<cmd>Octo pr create<CR>', { desc = '[O]cto [P]ull request create' })
vim.keymap.set('n', '<leader>oi', '<cmd>Octo issue list<CR>', { desc = '[O]cto [I]ssue list' })
vim.keymap.set('n', '<leader>oI', '<cmd>Octo issue create<CR>', { desc = '[O]cto [I]ssue create' })
vim.keymap.set('n', '<leader>on', '<cmd>Octo notification list<CR>', { desc = '[O]cto [N]otifications' })
vim.keymap.set('n', '<leader>os', '<cmd>Octo search<CR>', { desc = '[O]cto [S]earch GitHub' })
-- Review flow: start a review on the current PR, then submit or discard it.
vim.keymap.set('n', '<leader>or', '<cmd>Octo review start<CR>', { desc = '[O]cto [R]eview start' })
vim.keymap.set('n', '<leader>oR', '<cmd>Octo review submit<CR>', { desc = '[O]cto [R]eview submit' })
