-- Colorscheme: kanagawa (wave), with sonokai (andromeda) kept as an alternative.
-- Lives in lua/custom/plugins/ so it survives upstream syncs without conflicts.
-- See `:Telescope colorscheme` to preview installed themes.

vim.pack.add { 'https://github.com/sainnhe/sonokai' }
vim.g.sonokai_style = 'andromeda' -- warm, vivid Monokai-Pro-like palette
vim.g.sonokai_enable_italic = 1 -- italic keywords (comments are italic by default)
vim.g.sonokai_better_performance = 1

-- Extend italics beyond keywords/comments (VS Code "Dark+ Mono" look).
-- Reapplied on every ColorScheme so the overrides survive theme reloads.
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'sonokai',
  group = vim.api.nvim_create_augroup('sonokai-extra-italics', { clear = true }),
  callback = function()
    local italic_groups = {
      -- functions / types
      '@function',
      '@function.call',
      '@function.method',
      '@function.method.call',
      '@constructor',
      '@type',
      '@type.builtin',
      -- identifiers
      '@variable.parameter',
      '@variable.member',
      '@property',
      '@attribute',
      '@variable.builtin', -- this/self
    }
    for _, g in ipairs(italic_groups) do
      -- Merge italic into the existing definition so we keep the group's color.
      -- link = false resolves any link to concrete attributes.
      local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
      hl.italic = true
      vim.api.nvim_set_hl(0, g, hl)
    end
  end,
})

-- Alternative colorscheme: kanagawa (wave). Registered but not activated;
-- switch with `:colorscheme kanagawa` (or `:colorscheme sonokai` to switch back).
-- Styles tuned to match the sonokai look: italic functions/types, plain keywords.
vim.pack.add { 'https://github.com/rebelot/kanagawa.nvim' }
require('kanagawa').setup {
  theme = 'wave',
  dimInactive = true,
  commentStyle = { italic = true },
  functionStyle = { italic = true },
  typeStyle = { italic = true },
  keywordStyle = { italic = false }, -- no italic on keywords/control flow
  statementStyle = { bold = true },
  -- fujiGray (#727169) gives comments only 3.3:1 contrast on the wave
  -- background (#1f1f28), below the 4.5:1 readability bar. Lift to 8.5:1
  -- while keeping them a shade below code (Normal is 11.3:1).
  overrides = function()
    return {
      Comment = { fg = '#bfbab0', italic = true },
    }
  end,
}

vim.cmd.colorscheme 'kanagawa'
