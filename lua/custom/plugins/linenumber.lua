-- Line-number behavior tweaks (see also modicator.lua, which colors the cursor
-- line's number by mode).
--
-- Relative numbers are only useful for counted motions (5j, d3k, :+2), and none
-- of those exist in insert mode -- there the relative column is just noise that
-- shifts under the cursor. So drop back to plain absolute numbers while
-- inserting and restore relative numbers on the way out.
--
-- Driven by ModeChanged rather than InsertEnter/InsertLeave because CTRL-C can
-- leave insert mode without firing InsertLeave. We only act on the insert
-- boundary (`i` -> `ic`/`ix` and back are no-ops), and we only restore
-- 'relativenumber' in windows that actually had it on, so windows that
-- deliberately show absolute numbers are left alone.
local group = vim.api.nvim_create_augroup('custom-insert-absolute-numbers', { clear = true })

vim.api.nvim_create_autocmd('ModeChanged', {
  group = group,
  desc = "Use absolute 'number' instead of 'relativenumber' in insert mode",
  callback = function()
    local was_insert = vim.startswith(vim.v.event.old_mode, 'i')
    local is_insert = vim.startswith(vim.v.event.new_mode, 'i')
    if was_insert == is_insert then return end

    if is_insert then
      if vim.wo.relativenumber then
        vim.w.custom_restore_relativenumber = true
        vim.wo.relativenumber = false
      end
    elseif vim.w.custom_restore_relativenumber then
      vim.w.custom_restore_relativenumber = nil
      vim.wo.relativenumber = true
    end
  end,
})
