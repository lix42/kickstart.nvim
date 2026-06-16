-- modicator.nvim - color the cursor's line number by the current Vim mode
-- (normal/insert/visual/etc). Lives in lua/custom/plugins/ so it survives
-- upstream syncs without conflicts.
--
-- Prerequisites (all already set: number/cursorline in init.lua, termguicolors
-- at runtime). Modicator initializes its highlights on VimEnter and re-applies
-- on the Colorscheme event, so it works regardless of load order relative to
-- our colorscheme.lua. The default config also integrates with lualine (which
-- we use) to match mode colors.
vim.pack.add { 'https://github.com/mawkler/modicator.nvim' }

require('modicator').setup()
