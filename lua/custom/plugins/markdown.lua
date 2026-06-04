-- Markdown: in-editor rendering (render-markdown.nvim) + browser live preview
-- (markdown-preview.nvim). Lives in lua/custom/plugins/ so it survives upstream
-- syncs without conflicts.

-- [[ render-markdown.nvim ]] - in-editor rendering (no browser)
-- Renders headings, code blocks, tables, checkboxes, etc. inline using
-- treesitter. Active in normal mode, hides itself in insert mode so you can
-- edit the raw source. Reuses the existing treesitter + nvim-web-devicons.
-- The `markdown`/`markdown_inline` parsers are installed in init.lua Section 8.
vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {
  file_types = { 'markdown' },
}

-- [[ markdown-preview.nvim ]] - live preview in the browser
-- Build step: download the preview binary after install/update. The autocommand
-- is registered before `vim.pack.add` so it fires on a fresh install.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('markdown-preview-build', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name ~= 'markdown-preview.nvim' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    -- `mkdp#util#install()` lives in the plugin, so make sure it's loaded first.
    if not ev.data.active then vim.cmd.packadd 'markdown-preview.nvim' end
    vim.fn['mkdp#util#install']()
  end,
})
vim.pack.add { 'https://github.com/iamcco/markdown-preview.nvim' }
vim.g.mkdp_filetypes = { 'markdown' }
vim.g.mkdp_auto_close = 1 -- close the preview tab when leaving the markdown buffer

-- [[ Markdown keymaps ]]
require('which-key').add { { '<leader>m', group = '[M]arkdown' } }
vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<CR>', { desc = '[M]arkdown [R]ender toggle (in-editor)' })
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<CR>', { desc = '[M]arkdown [P]review toggle (browser)' })
