-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
        -- Use the fzy-based sorter so '/' does real fuzzy (subsequence) matching,
        -- not the default substring-only filter.
        ['/'] = 'fuzzy_sorter',
      },
    },
  },
  event_handlers = {
    -- Close the tree when a file is opened from it. Uses file_open_requested
    -- (not file_opened) so it also fires on the fuzzy-finder open path.
    {
      event = 'file_open_requested',
      handler = function() require('neo-tree.command').execute { action = 'close' } end,
    },
  },
}
