-- smear-cursor.nvim - animate the cursor with a smear/trail effect, Neovide-style
-- but in a plain terminal. Lives in lua/custom/plugins/ so it survives upstream
-- syncs without conflicts.
--
-- Note: the module name is `smear_cursor` (underscore), not the repo name.
-- It only animates the cursor glyph position, so it doesn't conflict with
-- modicator.nvim (which just recolors the CursorLineNr highlight).
vim.pack.add { 'https://github.com/sphamba/smear-cursor.nvim' }

require('smear_cursor').setup {}

-- Toggle the effect on/off (fits the [T]oggle which-key group).
vim.keymap.set('n', '<leader>ts', '<cmd>SmearCursorToggle<CR>', { desc = '[T]oggle [S]mear cursor' })
