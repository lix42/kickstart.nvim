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

-- Modicator derives the `<Mode>Mode` highlights from our lualine theme
-- (OceanicNext), which only defines mode colors for normal/insert/visual/
-- replace. Command, select and terminal silently fall back to the *normal*
-- color, so those modes are indistinguishable from normal at the line number.
-- Fill them in with the remaining OceanicNext base16 accents so every mode
-- gets its own hue:
--
--   normal   #6699CC blue     (lualine)   command  #FAC863 yellow
--   insert   #99C794 green    (lualine)   select   #C594C5 purple
--   visual   #F99157 orange   (lualine)   terminal #5FB3B3 cyan
--   replace  #EC5F67 red      (lualine)
--
-- TerminalNormal is intentionally left as-is: it mirrors normal mode, which is
-- what it is.
local mode_colors = {
  CommandMode = '#FAC863',
  SelectMode = '#C594C5',
  TerminalMode = '#5FB3B3',
}

-- Loading a colorscheme clears these, and modicator's own Colorscheme handler
-- won't overwrite a group that already exists -- so re-assert ours on every
-- colorscheme change, then repaint CursorLineNr for the mode we're in now.
local function apply_mode_colors()
  for name, fg in pairs(mode_colors) do
    vim.api.nvim_set_hl(0, name, { fg = fg })
  end

  local modicator = require 'modicator'
  modicator.set_cursor_line_highlight(modicator.hl_name_from_mode(vim.api.nvim_get_mode().mode))
end

-- Registered after setup(), so this runs after modicator's own Colorscheme
-- handler has filled in the lualine-derived groups.
vim.api.nvim_create_autocmd('Colorscheme', {
  group = vim.api.nvim_create_augroup('custom-modicator-mode-colors', { clear = true }),
  desc = 'Give command/select/terminal mode their own line-number colors',
  callback = apply_mode_colors,
})

apply_mode_colors()
