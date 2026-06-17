-- Move gitsigns hunk navigation off `]c`/`[c` onto `]h`/`[h`.
--
-- Why this lives here and not in `lua/kickstart/plugins/gitsigns.lua`:
-- upstream kickstart binds `]c`/`[c` (buffer-local, inside gitsigns' on_attach)
-- to hunk navigation, which collides with our treesitter "next/prev class"
-- motion on the same keys (see init.lua). Editing the kickstart module would
-- add an upstream-conflict surface; doing it here in custom/ survives rebases.
--
-- gitsigns offers no per-buffer "attached" autocmd, so we react to the maps
-- themselves appearing: once a buffer has gitsigns' buffer-local `]c`, we delete
-- `]c`/`[c` (letting them fall through to the global class motion) and bind
-- hunk nav to `]h`/`[h` instead.

local function has_buf_map(buf, lhs)
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, 'n')) do
    if m.lhs == lhs then return true end
  end
  return false
end

local function swap_hunk_nav()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].hunk_nav_remapped then return end
  -- Only act once gitsigns has actually attached and set its `]c` map.
  if not has_buf_map(buf, ']c') then return end

  local gs = require 'gitsigns'

  vim.keymap.del('n', ']c', { buffer = buf })
  vim.keymap.del('n', '[c', { buffer = buf })

  -- In a diff window, fall through to Vim's built-in `]c`/`[c` change motion
  -- (the `bang` makes `normal` ignore mappings, so the builtin is used).
  local function nav(dir, builtin)
    return function()
      if vim.wo.diff then
        vim.cmd.normal { builtin, bang = true }
      else
        gs.nav_hunk(dir)
      end
    end
  end

  vim.keymap.set('n', ']h', nav('next', ']c'), { buffer = buf, desc = 'Jump to next git [h]unk' })
  vim.keymap.set('n', '[h', nav('prev', '[c'), { buffer = buf, desc = 'Jump to previous git [h]unk' })

  vim.b[buf].hunk_nav_remapped = true
end

-- BufWinEnter catches buffers we navigate into; GitSignsUpdate fires after
-- gitsigns finishes attaching/refreshing. Either way we schedule the swap so it
-- runs after gitsigns has installed its own maps.
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'Rebind gitsigns hunk nav to ]h/[h',
  callback = function() vim.schedule(swap_hunk_nav) end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'GitSignsUpdate',
  desc = 'Rebind gitsigns hunk nav to ]h/[h after attach',
  callback = function() vim.schedule(swap_hunk_nav) end,
})
