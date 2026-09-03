-- LSP client log: silent by default, opt in when debugging a server.
--
-- Why OFF and not a lower level: vim/lsp/_transport.lua logs EVERY byte a
-- language server writes to stderr via log.error(), regardless of the server's
-- own severity. A server stuck in a crash/panic loop therefore writes unbounded
-- data at ERROR level, which the default WARN threshold happily lets through.
-- (A rust-analyzer panic loop grew lsp.log to 27 GB over two days once.)
-- Neovim has no log rotation; it only warns at startup past 1 GB.
--
-- The level is a plain module-local in vim.lsp.log, so :LspLogLevel takes
-- effect immediately -- no restart needed to start or stop capturing.

vim.lsp.log.set_level 'OFF'

local levels = { 'trace', 'debug', 'info', 'warn', 'error', 'off' }

vim.api.nvim_create_user_command('LspLogLevel', function(opts)
  if opts.args == '' then
    vim.notify('LSP log level: ' .. vim.lsp.log.levels[vim.lsp.log.get_level()], vim.log.levels.INFO)
    return
  end
  vim.lsp.log.set_level(opts.args)
  vim.notify('LSP log level -> ' .. opts.args:upper(), vim.log.levels.INFO)
end, {
  nargs = '?',
  complete = function(arg)
    return vim.tbl_filter(function(l)
      return l:find(arg, 1, true) == 1
    end, levels)
  end,
  desc = 'Get/set the LSP client log level (no args = show current)',
})

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd.tabnew(vim.lsp.log.get_filename())
end, { desc = 'Open the LSP client log file' })

-- Truncate rather than delete: Neovim holds the log open in append mode for the
-- whole session, so unlinking it would not free the space until every nvim exits.
vim.api.nvim_create_user_command('LspLogClear', function()
  local path = vim.lsp.log.get_filename()
  local fd = assert(vim.uv.fs_open(path, 'w', 420))
  vim.uv.fs_close(fd)
  vim.notify('Truncated ' .. path, vim.log.levels.INFO)
end, { desc = 'Truncate the LSP client log file' })
