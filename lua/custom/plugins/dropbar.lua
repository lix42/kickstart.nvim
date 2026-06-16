-- dropbar.nvim - IDE-like breadcrumb navigation in the winbar, with drop-down
-- menus for jumping to symbols. Lives in lua/custom/plugins/ so it survives
-- upstream syncs without conflicts.
--
-- Icons: dropbar uses nvim-web-devicons when present. We don't install it, but
-- mini.icons' mock_nvim_web_devicons() shim (set up in init.lua) satisfies that
-- require, so filetype icons still render. LSP/treesitter backends use the
-- built-in servers/parsers already configured. Needs Neovim >= 0.11.
vim.pack.add { 'https://github.com/Bekaboo/dropbar.nvim' }

require('dropbar').setup {}

-- Interactive navigation of the breadcrumb (leader is `,`, so this is `,;`).
local api = require 'dropbar.api'
vim.keymap.set('n', '<leader>;', api.pick, { desc = 'Dropbar: [;] pick symbol' })
vim.keymap.set('n', '[;', api.goto_context_start, { desc = 'Dropbar: go to context start' })
vim.keymap.set('n', '];', api.select_next_context, { desc = 'Dropbar: select next context' })
